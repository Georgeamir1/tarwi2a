import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tarwi2a/domain/enums/notification_type.dart';
import 'package:tarwi2a/domain/failures/failure.dart';
import 'package:tarwi2a/infrastructure/datasources/remote/notification_remote_datasource.dart';
import 'package:tarwi2a/infrastructure/dtos/notification_dto.dart';
import 'package:tarwi2a/infrastructure/dtos/notification_preference_dto.dart';
import 'package:tarwi2a/infrastructure/repositories/notification_repository_impl.dart';

class MockNotificationRemoteDataSource extends Mock
    implements NotificationRemoteDataSource {}

NotificationDTO _dto({
  String id = 'n1',
  String userId = 'u1',
  String type = 'order_confirmed',
  bool isRead = false,
  String? referenceType = 'order',
  String? referenceId = 'o1',
}) {
  return NotificationDTO(
    id: id,
    userId: userId,
    titleAr: 'تم تأكيد طلبك',
    bodyAr: 'طلبك #ABC12345',
    type: type,
    referenceType: referenceType,
    referenceId: referenceId,
    isRead: isRead,
    createdAt: DateTime(2026, 6, 1),
  );
}

NotificationPreferenceDTO _prefDto({
  String id = 'p1',
  String userId = 'u1',
  bool orderUpdates = true,
  bool promotions = true,
  bool pushEnabled = true,
}) {
  return NotificationPreferenceDTO(
    id: id,
    userId: userId,
    orderUpdates: orderUpdates,
    promotions: promotions,
    pushEnabled: pushEnabled,
    updatedAt: DateTime(2026, 6, 1),
  );
}

void main() {
  late MockNotificationRemoteDataSource mockDS;
  late NotificationRepositoryImpl repo;

  setUp(() {
    mockDS = MockNotificationRemoteDataSource();
    repo = NotificationRepositoryImpl(mockDS);
  });

  group('NotificationRepositoryImpl', () {
    test('getNotifications returns mapped entities on success', () async {
      when(() => mockDS.getNotifications(
            userId: any(named: 'userId'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => [_dto()]);

      final result = await repo.getNotifications(userId: 'u1');

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected right'),
        (notifications) {
          expect(notifications, hasLength(1));
          expect(notifications.first.type, NotificationType.orderConfirmed);
          expect(notifications.first.titleAr, 'تم تأكيد طلبك');
          expect(notifications.first.referenceId, 'o1');
        },
      );
    });

    test('getNotifications returns failure on exception', () async {
      when(() => mockDS.getNotifications(
            userId: any(named: 'userId'),
            limit: any(named: 'limit'),
          )).thenThrow(Exception('boom'));

      final result = await repo.getNotifications(userId: 'u1');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<UnexpectedFailure>()),
        (_) => fail('Expected left'),
      );
    });

    test('getUnreadCount returns count on success', () async {
      when(() => mockDS.getUnreadCount(userId: any(named: 'userId')))
          .thenAnswer((_) async => 5);

      final result = await repo.getUnreadCount(userId: 'u1');

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected right'),
        (count) => expect(count, 5),
      );
    });

    test('markAsRead returns right on success', () async {
      when(() => mockDS.markAsRead(any())).thenAnswer((_) async {});

      final result = await repo.markAsRead('n1');

      expect(result, Right<Failure, void>(null));
    });

    test('markAllAsRead returns right on success', () async {
      when(() => mockDS.markAllAsRead(userId: any(named: 'userId')))
          .thenAnswer((_) async {});

      final result = await repo.markAllAsRead(userId: 'u1');

      expect(result, Right<Failure, void>(null));
    });

    test('markDelivered returns right on success', () async {
      when(() => mockDS.markDelivered(any())).thenAnswer((_) async {});

      final result = await repo.markDelivered('n1');

      expect(result, Right<Failure, void>(null));
    });

    test('markOpened returns right on success', () async {
      when(() => mockDS.markOpened(any())).thenAnswer((_) async {});

      final result = await repo.markOpened('n1');

      expect(result, Right<Failure, void>(null));
    });

    test('createNotification returns right on success', () async {
      when(() => mockDS.createNotification(
            userId: any(named: 'userId'),
            titleAr: any(named: 'titleAr'),
            bodyAr: any(named: 'bodyAr'),
            type: any(named: 'type'),
            referenceType: any(named: 'referenceType'),
            referenceId: any(named: 'referenceId'),
          )).thenAnswer((_) async {});

      final result = await repo.createNotification(
        userId: 'u1',
        titleAr: 't',
        bodyAr: 'b',
        type: 'system',
      );

      expect(result, Right<Failure, void>(null));
    });

    test('getPreferences returns defaults when null', () async {
      when(() => mockDS.getPreferences(userId: any(named: 'userId')))
          .thenAnswer((_) async => null);

      final result = await repo.getPreferences(userId: 'u1');

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected right'),
        (prefs) {
          expect(prefs.userId, 'u1');
          expect(prefs.pushEnabled, isTrue);
        },
      );
    });

    test('getPreferences returns mapped prefs', () async {
      when(() => mockDS.getPreferences(userId: any(named: 'userId')))
          .thenAnswer((_) async => _prefDto(promotions: false));

      final result = await repo.getPreferences(userId: 'u1');

      result.fold(
        (_) => fail('Expected right'),
        (prefs) => expect(prefs.promotions, isFalse),
      );
    });

    test('updatePreferences returns updated entity', () async {
      when(() => mockDS.upsertPreferences(
            userId: any(named: 'userId'),
            orderUpdates: any(named: 'orderUpdates'),
            promotions: any(named: 'promotions'),
            pushEnabled: any(named: 'pushEnabled'),
          )).thenAnswer((_) async => _prefDto(orderUpdates: false));

      final result =
          await repo.updatePreferences(userId: 'u1', orderUpdates: false);

      result.fold(
        (_) => fail('Expected right'),
        (prefs) => expect(prefs.orderUpdates, isFalse),
      );
    });

    test('watchNotifications maps stream of DTOs to entities', () async {
      when(() => mockDS.watchNotifications(userId: any(named: 'userId')))
          .thenAnswer((_) => Stream.value([_dto(type: 'system')]));

      final stream = repo.watchNotifications(userId: 'u1');
      final result = await stream.first;

      expect(result, hasLength(1));
      expect(result.first.type, NotificationType.system);
    });
  });
}
