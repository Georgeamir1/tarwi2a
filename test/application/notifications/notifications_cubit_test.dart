import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tarwi2a/application/notifications/notifications_cubit.dart';
import 'package:tarwi2a/domain/entities/app_notification.dart';
import 'package:tarwi2a/domain/enums/notification_type.dart';
import 'package:tarwi2a/domain/repositories/notification_repository.dart';
import '../../helpers/test_helpers.dart';

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

void main() {
  late MockNotificationRepository mockRepo;
  late NotificationsCubit cubit;

  final tNotification = AppNotification(
    id: 'n1',
    userId: 'u1',
    titleAr: 'تم تأكيد طلبك',
    bodyAr: 'طلبك #ABC12345 تم تأكيده',
    type: NotificationType.orderConfirmed,
    referenceType: 'order',
    referenceId: 'o1',
    isRead: false,
    createdAt: DateTime(2026, 6, 1),
  );

  setUpAll(() {
    registerFallbackValue(testServerFailure);
  });

  setUp(() {
    mockRepo = MockNotificationRepository();
    when(() => mockRepo.watchNotifications(userId: any(named: 'userId')))
        .thenAnswer((_) => const Stream.empty());
    cubit = NotificationsCubit(mockRepo);
  });

  tearDown(() {
    cubit.close();
  });

  group('NotificationsCubit', () {
    test('initial state is correct', () {
      expect(cubit.state.status, NotificationsStatus.initial);
      expect(cubit.state.notifications, isEmpty);
      expect(cubit.state.unreadCount, 0);
    });

    test('loadNotifications emits loaded with notifications', () async {
      when(() => mockRepo.getNotifications(
            userId: any(named: 'userId'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => right([tNotification]));

      await cubit.loadNotifications('u1');

      expect(cubit.state.status, NotificationsStatus.loaded);
      expect(cubit.state.notifications, [tNotification]);
      expect(cubit.state.unreadCount, 1);
    });

    test('loadNotifications emits error on failure', () async {
      when(() => mockRepo.getNotifications(
            userId: any(named: 'userId'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => left(testServerFailure));

      await cubit.loadNotifications('u1');

      expect(cubit.state.status, NotificationsStatus.error);
      expect(cubit.state.failure, testServerFailure);
    });

    test('loadNotifications subscribes to stream', () async {
      when(() => mockRepo.getNotifications(
            userId: any(named: 'userId'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => right([tNotification]));

      await cubit.loadNotifications('u1');

      verify(() => mockRepo.watchNotifications(userId: 'u1')).called(1);
    });

    test('markAsRead updates notification + unread count', () async {
      when(() => mockRepo.getNotifications(
            userId: any(named: 'userId'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => right([tNotification]));
      when(() => mockRepo.markAsRead(any()))
          .thenAnswer((_) async => right(null));
      when(() => mockRepo.markOpened(any()))
          .thenAnswer((_) async => right(null));

      await cubit.loadNotifications('u1');
      expect(cubit.state.unreadCount, 1);

      await cubit.markAsRead('n1');

      expect(cubit.state.notifications.first.isRead, isTrue);
      expect(cubit.state.unreadCount, 0);
    });

    test('markAllAsRead updates all notifications', () async {
      final t2 = tNotification.copyWith(isRead: true);
      final t3 = tNotification.copyWith(id: 'n2');
      when(() => mockRepo.getNotifications(
            userId: any(named: 'userId'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => right([tNotification, t2, t3]));
      when(() => mockRepo.markAllAsRead(userId: any(named: 'userId')))
          .thenAnswer((_) async => right(null));

      await cubit.loadNotifications('u1');
      expect(cubit.state.unreadCount, 2);

      await cubit.markAllAsRead('u1');

      expect(cubit.state.unreadCount, 0);
      expect(
        cubit.state.notifications.every((n) => n.isRead),
        isTrue,
      );
    });

    test('switchUser resets state and reloads', () async {
      when(() => mockRepo.getNotifications(
            userId: any(named: 'userId'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => right([tNotification]));

      await cubit.loadNotifications('u1');
      expect(cubit.state.notifications, isNotEmpty);

      cubit.switchUser('u2');
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // After switchUser, state should be loaded with new user
      expect(cubit.state.status, NotificationsStatus.loaded);
    });

    test('stream emit updates notifications', () async {
      final controller = StreamController<List<AppNotification>>();
      when(() => mockRepo.getNotifications(
            userId: any(named: 'userId'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => right([]));
      when(() => mockRepo.watchNotifications(userId: any(named: 'userId')))
          .thenAnswer((_) => controller.stream);

      await cubit.loadNotifications('u1');

      controller.add([tNotification]);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(cubit.state.notifications, [tNotification]);
      expect(cubit.state.unreadCount, 1);
      await controller.close();
    });

    test('stream error does not crash cubit', () async {
      final controller = StreamController<List<AppNotification>>();
      when(() => mockRepo.getNotifications(
            userId: any(named: 'userId'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => right([]));
      when(() => mockRepo.watchNotifications(userId: any(named: 'userId')))
          .thenAnswer((_) => controller.stream);

      await cubit.loadNotifications('u1');
      controller.addError(Exception('stream error'));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(cubit.state.status, NotificationsStatus.error);
      await controller.close();
    });
  });
}
