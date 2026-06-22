import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tarwi2a/application/admin/admin_broadcast_cubit.dart';
import 'package:tarwi2a/domain/entities/broadcast_log.dart';
import 'package:tarwi2a/domain/entities/broadcast_notification.dart';
import 'package:tarwi2a/domain/enums/broadcast_target.dart';
import 'package:tarwi2a/domain/enums/notification_type.dart';
import 'package:tarwi2a/domain/repositories/broadcast_repository.dart';
import '../../helpers/test_helpers.dart';

class MockBroadcastRepository extends Mock implements BroadcastRepository {}

void main() {
  late MockBroadcastRepository mockRepo;
  late AdminBroadcastCubit cubit;

  setUpAll(() {
    registerFallbackValue(testServerFailure);
    registerFallbackValue(
      BroadcastNotification(
        titleAr: '',
        bodyAr: '',
        type: NotificationType.promotion,
        targetType: BroadcastTargetType.all,
      ),
    );
    registerFallbackValue(BroadcastTargetType.all);
    registerFallbackValue(<String>[]);
  });

  setUp(() {
    mockRepo = MockBroadcastRepository();
    cubit = AdminBroadcastCubit(mockRepo);
  });

  tearDown(() {
    cubit.close();
  });

  group('AdminBroadcastCubit', () {
    test('initial state is correct', () {
      expect(cubit.state.status, AdminBroadcastStatus.initial);
      expect(cubit.state.history, isEmpty);
      expect(cubit.state.previewRecipientsCount, isNull);
    });

    test('loadHistory emits loaded with history list on success', () async {
      final logs = [
        BroadcastLog(
          id: '1',
          titleAr: 'Test',
          bodyAr: 'Body',
          type: NotificationType.promotion,
          targetType: BroadcastTargetType.customers,
          recipientCount: 100,
          sentCount: 95,
          skippedCount: 5,
          createdAt: DateTime.now(),
        ),
      ];
      when(() => mockRepo.getHistory(limit: any(named: 'limit')))
          .thenAnswer((_) async => right(logs));

      final emitted = <AdminBroadcastState>[];
      final sub = cubit.stream.listen(emitted.add);

      await cubit.loadHistory();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await sub.cancel();

      expect(emitted.first.status, AdminBroadcastStatus.loading);
      expect(emitted.last.status, AdminBroadcastStatus.loaded);
      expect(emitted.last.history, logs);
    });

    test('loadHistory emits error on failure', () async {
      when(() => mockRepo.getHistory(limit: any(named: 'limit')))
          .thenAnswer((_) async => left(testServerFailure));

      await cubit.loadHistory();

      expect(cubit.state.status, AdminBroadcastStatus.error);
      expect(cubit.state.failure, testServerFailure);
    });

    test('previewRecipients updates count', () async {
      when(() => mockRepo.getRecipientsCount(
            targetType: any(named: 'targetType'),
            targetUserIds: any(named: 'targetUserIds'),
          )).thenAnswer((_) async => right(1234));

      await cubit.previewRecipients(
        targetType: BroadcastTargetType.customers,
      );

      expect(cubit.state.previewRecipientsCount, 1234);
      expect(cubit.state.previewTargetType, BroadcastTargetType.customers);
    });

    test('sendBroadcast with empty title returns false', () async {
      final result = await cubit.sendBroadcast(
        titleAr: '  ',
        bodyAr: 'body',
        type: NotificationType.promotion,
        targetType: BroadcastTargetType.all,
        senderId: 'admin-1',
      );
      expect(result, isFalse);
      expect(cubit.state.status, AdminBroadcastStatus.error);
    });

    test('sendBroadcast with empty body returns false', () async {
      final result = await cubit.sendBroadcast(
        titleAr: 'title',
        bodyAr: '',
        type: NotificationType.promotion,
        targetType: BroadcastTargetType.all,
        senderId: 'admin-1',
      );
      expect(result, isFalse);
      expect(cubit.state.status, AdminBroadcastStatus.error);
    });

    test('sendBroadcast with specific target and empty userIds returns false',
        () async {
      final result = await cubit.sendBroadcast(
        titleAr: 'title',
        bodyAr: 'body',
        type: NotificationType.promotion,
        targetType: BroadcastTargetType.specific,
        targetUserIds: const [],
        senderId: 'admin-1',
      );
      expect(result, isFalse);
      expect(cubit.state.status, AdminBroadcastStatus.error);
    });

    test('sendBroadcast success emits sent and reloads history', () async {
      when(() => mockRepo.sendBroadcast(
            broadcast: any(named: 'broadcast'),
            senderId: any(named: 'senderId'),
          )).thenAnswer((_) async => right(
            const BroadcastResult(
              recipientCount: 100,
              sentCount: 100,
              skippedCount: 0,
            ),
          ));
      when(() => mockRepo.getHistory(limit: any(named: 'limit')))
          .thenAnswer((_) async => right(<BroadcastLog>[]));

      final emitted = <AdminBroadcastState>[];
      final sub = cubit.stream.listen(emitted.add);

      final ok = await cubit.sendBroadcast(
        titleAr: 'Test promotion',
        bodyAr: 'Body content',
        type: NotificationType.promotion,
        targetType: BroadcastTargetType.all,
        senderId: 'admin-1',
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await sub.cancel();

      expect(ok, isTrue);
      final sentState =
          emitted.firstWhere((s) => s.status == AdminBroadcastStatus.sent);
      expect(sentState.lastResult?.sentCount, 100);
    });

    test('sendBroadcast failure emits error', () async {
      when(() => mockRepo.sendBroadcast(
            broadcast: any(named: 'broadcast'),
            senderId: any(named: 'senderId'),
          )).thenAnswer((_) async => left(testNetworkFailure));

      final ok = await cubit.sendBroadcast(
        titleAr: 'Test',
        bodyAr: 'Body',
        type: NotificationType.promotion,
        targetType: BroadcastTargetType.all,
        senderId: 'admin-1',
      );
      expect(ok, isFalse);
      expect(cubit.state.status, AdminBroadcastStatus.error);
    });
  });
}
