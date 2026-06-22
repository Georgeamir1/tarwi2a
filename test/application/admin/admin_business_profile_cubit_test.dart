import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tarwi2a/application/admin/admin_business_profile_cubit.dart';
import 'package:tarwi2a/domain/failures/failure.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late MockBusinessProfileRepository mockRepo;
  late AdminBusinessProfileCubit cubit;

  setUpAll(() {
    registerFallbackValue(testServerFailure);
    registerFallbackValue(testBusinessProfile);
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    mockRepo = MockBusinessProfileRepository();
    when(() => mockRepo.watchProfile())
        .thenAnswer((_) => const Stream.empty());
  });

  group('AdminBusinessProfileCubit', () {
    test('initial state is correct', () {
      cubit = AdminBusinessProfileCubit(mockRepo);
      expect(cubit.state.status, AdminBusinessProfileStatus.initial);
      expect(cubit.state.profile, isNull);
    });

    test('loadProfile emits loaded with profile on success', () async {
      when(() => mockRepo.get())
          .thenAnswer((_) async => right(testBusinessProfile));

      cubit = AdminBusinessProfileCubit(mockRepo);
      await cubit.loadProfile();

      expect(cubit.state.status, AdminBusinessProfileStatus.loaded);
      expect(cubit.state.profile!.name, 'ترويقه');
      verify(() => mockRepo.get()).called(1);
    });

    test('loadProfile emits error on failure', () async {
      when(() => mockRepo.get())
          .thenAnswer((_) async => left(testServerFailure));

      cubit = AdminBusinessProfileCubit(mockRepo);
      await cubit.loadProfile();

      expect(cubit.state.status, AdminBusinessProfileStatus.error);
      expect(cubit.state.failure, testServerFailure);
    });

    test('toggleAcceptOrders calls repo then reloads', () async {
      when(() => mockRepo.toggleAcceptOrders(any()))
          .thenAnswer((_) async => right<Failure, void>(null));
      when(() => mockRepo.get())
          .thenAnswer((_) async => right(testBusinessProfile));

      cubit = AdminBusinessProfileCubit(mockRepo);
      await cubit.toggleAcceptOrders(false);
      await Future.delayed(const Duration(milliseconds: 50));

      verify(() => mockRepo.toggleAcceptOrders(false)).called(1);
      expect(cubit.state.status, AdminBusinessProfileStatus.loaded);
    });

    test('toggleBusyMode calls repo then reloads', () async {
      when(() => mockRepo.toggleBusyMode(
            isBusy: any(named: 'isBusy'),
            message: any(named: 'message'),
          )).thenAnswer((_) async => right<Failure, void>(null));
      when(() => mockRepo.get())
          .thenAnswer((_) async => right(testBusinessProfile));

      cubit = AdminBusinessProfileCubit(mockRepo);
      await cubit.toggleBusyMode(
        isBusy: true,
        message: 'وقت التحضير أطول',
      );
      await Future.delayed(const Duration(milliseconds: 50));

      verify(() => mockRepo.toggleBusyMode(
            isBusy: true,
            message: 'وقت التحضير أطول',
          )).called(1);
      expect(cubit.state.status, AdminBusinessProfileStatus.loaded);
    });
  });
}
