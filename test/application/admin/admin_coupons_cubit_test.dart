import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tarwi2a/application/admin/admin_coupons_cubit.dart';
import 'package:tarwi2a/domain/entities/coupon.dart';
import 'package:tarwi2a/domain/failures/failure.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late MockCouponRepository mockRepo;
  late AdminCouponsCubit cubit;

  setUpAll(() {
    registerFallbackValue(testServerFailure);
    registerFallbackValue(<Coupon>[]);
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    mockRepo = MockCouponRepository();
    when(() => mockRepo.watchCoupons())
        .thenAnswer((_) => const Stream.empty());
  });

  group('AdminCouponsCubit', () {
    test('initial state is correct', () {
      cubit = AdminCouponsCubit(mockRepo);
      expect(cubit.state.status, AdminCouponsStatus.initial);
      expect(cubit.state.coupons, isEmpty);
    });

    test('loadCoupons emits loaded with data on success', () async {
      when(() => mockRepo.getAll())
          .thenAnswer((_) async => right([testCoupon]));

      cubit = AdminCouponsCubit(mockRepo);
      await cubit.loadCoupons();

      expect(cubit.state.status, AdminCouponsStatus.loaded);
      expect(cubit.state.coupons, [testCoupon]);
      verify(() => mockRepo.getAll()).called(1);
    });

    test('loadCoupons emits error on failure', () async {
      when(() => mockRepo.getAll())
          .thenAnswer((_) async => left(testServerFailure));

      cubit = AdminCouponsCubit(mockRepo);
      await cubit.loadCoupons();

      expect(cubit.state.status, AdminCouponsStatus.error);
      expect(cubit.state.failure, testServerFailure);
    });

    test('create calls repo.create then reloads', () async {
      when(() => mockRepo.create(any()))
          .thenAnswer((_) async => right<Failure, void>(null));
      when(() => mockRepo.getAll())
          .thenAnswer((_) async => right([testCoupon]));

      cubit = AdminCouponsCubit(mockRepo);
      await cubit.create({'code': 'NEW', 'type': 'percentage', 'value': 10});
      await Future.delayed(const Duration(milliseconds: 50));

      verify(() => mockRepo.create(any())).called(1);
      expect(cubit.state.status, AdminCouponsStatus.loaded);
    });

    test('toggleActive calls repo.toggleActive then reloads', () async {
      when(() => mockRepo.toggleActive(any(), any()))
          .thenAnswer((_) async => right<Failure, void>(null));
      when(() => mockRepo.getAll())
          .thenAnswer((_) async => right([testCoupon]));

      cubit = AdminCouponsCubit(mockRepo);
      await cubit.toggleActive('coupon-1', false);
      await Future.delayed(const Duration(milliseconds: 50));

      verify(() => mockRepo.toggleActive('coupon-1', false)).called(1);
      expect(cubit.state.status, AdminCouponsStatus.loaded);
    });
  });
}
