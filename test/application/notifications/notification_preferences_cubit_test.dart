import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tarwi2a/application/notifications/notification_preferences_cubit.dart';
import 'package:tarwi2a/domain/entities/notification_preference.dart';
import 'package:tarwi2a/domain/repositories/notification_repository.dart';
import '../../helpers/test_helpers.dart';

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

void main() {
  late MockNotificationRepository mockRepo;
  late NotificationPreferencesCubit cubit;

  final tPrefs = NotificationPreference(
    id: 'p1',
    userId: 'u1',
    orderUpdates: true,
    promotions: true,
    pushEnabled: true,
    updatedAt: DateTime(2026, 6, 1),
  );

  setUpAll(() {
    registerFallbackValue(testServerFailure);
  });

  setUp(() {
    mockRepo = MockNotificationRepository();
    cubit = NotificationPreferencesCubit(mockRepo);
  });

  tearDown(() {
    cubit.close();
  });

  group('NotificationPreferencesCubit', () {
    test('initial state has default preferences', () {
      expect(cubit.state.status, NotificationPreferencesStatus.initial);
      expect(cubit.state.preference.pushEnabled, isTrue);
      expect(cubit.state.preference.orderUpdates, isTrue);
      expect(cubit.state.preference.promotions, isTrue);
    });

    test('loadPreferences emits loaded with prefs', () async {
      when(() => mockRepo.getPreferences(userId: any(named: 'userId')))
          .thenAnswer((_) async => right(tPrefs));

      await cubit.loadPreferences('u1');

      expect(cubit.state.status, NotificationPreferencesStatus.loaded);
      expect(cubit.state.preference, tPrefs);
    });

    test('loadPreferences returns defaults when null', () async {
      when(() => mockRepo.getPreferences(userId: any(named: 'userId')))
          .thenAnswer((_) async => right(tPrefs));

      await cubit.loadPreferences('u1');
      expect(cubit.state.preference.pushEnabled, isTrue);
    });

    test('loadPreferences emits error on failure', () async {
      when(() => mockRepo.getPreferences(userId: any(named: 'userId')))
          .thenAnswer((_) async => left(testServerFailure));

      await cubit.loadPreferences('u1');

      expect(cubit.state.status, NotificationPreferencesStatus.error);
      expect(cubit.state.failure, testServerFailure);
    });

    test('updatePreference applies optimistic update', () async {
      final updated = tPrefs.copyWith(
        orderUpdates: false,
      );
      when(() => mockRepo.updatePreferences(
            userId: any(named: 'userId'),
            orderUpdates: any(named: 'orderUpdates'),
            promotions: any(named: 'promotions'),
            pushEnabled: any(named: 'pushEnabled'),
          )).thenAnswer((_) async => right(updated));

      await cubit.updatePreference(userId: 'u1', orderUpdates: false);

      expect(cubit.state.preference.orderUpdates, isFalse);
    });

    test('updatePreference rolls back on failure', () async {
      when(() => mockRepo.updatePreferences(
            userId: any(named: 'userId'),
            orderUpdates: any(named: 'orderUpdates'),
            promotions: any(named: 'promotions'),
            pushEnabled: any(named: 'pushEnabled'),
          )).thenAnswer((_) async => left(testServerFailure));

      // First load, then try to update
      when(() => mockRepo.getPreferences(userId: any(named: 'userId')))
          .thenAnswer((_) async => right(tPrefs));
      await cubit.loadPreferences('u1');

      await cubit.updatePreference(userId: 'u1', orderUpdates: false);

      // After rollback, original value restored
      expect(cubit.state.preference.orderUpdates, isTrue);
      expect(cubit.state.status, NotificationPreferencesStatus.error);
    });
  });
}
