import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tarwi2a/domain/entities/broadcast_notification.dart';
import 'package:tarwi2a/domain/enums/broadcast_target.dart';
import 'package:tarwi2a/domain/enums/notification_type.dart';
import 'package:tarwi2a/infrastructure/datasources/remote/broadcast_remote_datasource.dart';
import 'package:tarwi2a/infrastructure/dtos/broadcast_log_dto.dart';
import 'package:tarwi2a/infrastructure/repositories/broadcast_repository_impl.dart';

class MockBroadcastRemoteDataSource extends Mock
    implements BroadcastRemoteDataSource {}

BroadcastLogDTO _logDto({
  String id = 'bl1',
  String type = 'promotion',
  String targetType = 'all',
  int recipientCount = 100,
  int sentCount = 95,
  int skippedCount = 5,
}) {
  return BroadcastLogDTO(
    id: id,
    senderId: 'admin-1',
    titleAr: 'عرض جديد',
    bodyAr: 'خصم 20%',
    type: type,
    targetType: targetType,
    recipientCount: recipientCount,
    sentCount: sentCount,
    skippedCount: skippedCount,
    createdAt: DateTime(2026, 6, 1),
  );
}

BroadcastNotification _broadcast() {
  return const BroadcastNotification(
    titleAr: 'Test',
    bodyAr: 'Body',
    type: NotificationType.promotion,
    targetType: BroadcastTargetType.all,
  );
}

void main() {
  late MockBroadcastRemoteDataSource mockDS;
  late BroadcastRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(_broadcast());
    registerFallbackValue(BroadcastTargetType.all);
    registerFallbackValue(NotificationType.promotion);
    registerFallbackValue(<String>[]);
  });

  setUp(() {
    mockDS = MockBroadcastRemoteDataSource();
    repo = BroadcastRepositoryImpl(mockDS);
  });

  group('BroadcastRepositoryImpl', () {
    test('sendBroadcast returns result on success', () async {
      when(() => mockDS.sendBroadcast(
            broadcast: any(named: 'broadcast'),
            senderId: any(named: 'senderId'),
          )).thenAnswer((_) async => BroadcastResultDto(
            recipientCount: 100,
            sentCount: 95,
            skippedCount: 5,
          ));

      final result = await repo.sendBroadcast(
        broadcast: _broadcast(),
        senderId: 'admin-1',
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected right'),
        (r) {
          expect(r.recipientCount, 100);
          expect(r.sentCount, 95);
          expect(r.skippedCount, 5);
        },
      );
    });

    test('sendBroadcast returns left on failure', () async {
      when(() => mockDS.sendBroadcast(
            broadcast: any(named: 'broadcast'),
            senderId: any(named: 'senderId'),
          )).thenThrow(Exception('boom'));

      final result = await repo.sendBroadcast(
        broadcast: _broadcast(),
        senderId: 'admin-1',
      );

      expect(result.isLeft(), isTrue);
    });

    test('getHistory returns mapped logs', () async {
      when(() => mockDS.getHistory(limit: any(named: 'limit')))
          .thenAnswer((_) async => [_logDto()]);

      final result = await repo.getHistory();

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected right'),
        (logs) {
          expect(logs, hasLength(1));
          expect(logs.first.type, NotificationType.promotion);
          expect(logs.first.targetType, BroadcastTargetType.all);
          expect(logs.first.recipientCount, 100);
        },
      );
    });

    test('getRecipientsCount returns count for all', () async {
      when(() => mockDS.getRecipientsCount(
            targetType: any(named: 'targetType'),
            targetUserIds: any(named: 'targetUserIds'),
          )).thenAnswer((_) async => 1234);

      final result = await repo.getRecipientsCount(
        targetType: BroadcastTargetType.all,
      );

      result.fold(
        (_) => fail('Expected right'),
        (count) => expect(count, 1234),
      );
    });

    test('getRecipientsCount delegates to DS for specific target', () async {
      when(() => mockDS.getRecipientsCount(
            targetType: any(named: 'targetType'),
            targetUserIds: any(named: 'targetUserIds'),
          )).thenAnswer((_) async => 3);

      final result = await repo.getRecipientsCount(
        targetType: BroadcastTargetType.specific,
        targetUserIds: const ['u1', 'u2', 'u3'],
      );

      result.fold(
        (_) => fail('Expected right'),
        (count) => expect(count, 3),
      );
    });

    test('getRecipientsCount returns left on failure', () async {
      when(() => mockDS.getRecipientsCount(
            targetType: any(named: 'targetType'),
            targetUserIds: any(named: 'targetUserIds'),
          )).thenThrow(Exception('boom'));

      final result = await repo.getRecipientsCount(
        targetType: BroadcastTargetType.customers,
      );

      expect(result.isLeft(), isTrue);
    });
  });
}
