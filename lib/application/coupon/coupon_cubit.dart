import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/coupon.dart';
import '../../domain/enums/coupon_type.dart';
import '../../domain/repositories/coupon_repository.dart';
import '../../core/logger/app_logger.dart';

enum CouponStatus { initial, validating, applied, error, removing }

class CouponState extends Equatable {
  final Coupon? appliedCoupon;
  final double discountAmount;
  final CouponStatus status;
  final String? errorMessage;

  const CouponState({
    this.appliedCoupon,
    this.discountAmount = 0,
    this.status = CouponStatus.initial,
    this.errorMessage,
  });

  CouponState copyWith({
    Coupon? appliedCoupon,
    double? discountAmount,
    CouponStatus? status,
    String? errorMessage,
  }) {
    return CouponState(
      appliedCoupon: appliedCoupon ?? this.appliedCoupon,
      discountAmount: discountAmount ?? this.discountAmount,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [appliedCoupon, discountAmount, status, errorMessage];
}

class CouponCubit extends Cubit<CouponState> {
  final CouponRepository _repository;

  CouponCubit(this._repository) : super(const CouponState());

  Future<void> validateAndApply(String code, double orderTotal) async {
    appLogger.i('[CouponCubit] validateAndApply: code=$code, total=$orderTotal');
    emit(state.copyWith(status: CouponStatus.validating));

    final result = await _repository.getByCode(code);
    result.fold(
      (failure) {
        appLogger.w('[CouponCubit] repo error: ${failure.message}');
        emit(state.copyWith(
          status: CouponStatus.error,
          errorMessage: 'حصل خطأ، حاول تاني',
        ));
      },
      (coupon) {
        if (coupon == null) {
          emit(state.copyWith(
            status: CouponStatus.error,
            errorMessage: 'كود الخصم غير صالح',
          ));
          return;
        }

        final validationError = _validate(coupon, orderTotal);
        if (validationError != null) {
          emit(state.copyWith(
            status: CouponStatus.error,
            errorMessage: validationError,
          ));
          return;
        }

        final discount = _calculateDiscount(coupon, orderTotal);
        appLogger.i('[CouponCubit] applied: ${coupon.code}, discount=$discount');
        emit(state.copyWith(
          appliedCoupon: coupon,
          discountAmount: discount,
          status: CouponStatus.applied,
          errorMessage: null,
        ));
      },
    );
  }

  void removeCoupon() {
    appLogger.i('[CouponCubit] removeCoupon');
    emit(state.copyWith(
      appliedCoupon: null,
      discountAmount: 0,
      status: CouponStatus.removing,
      errorMessage: null,
    ));
    emit(const CouponState());
  }

  void clearError() {
    if (state.status == CouponStatus.error) {
      emit(state.copyWith(status: CouponStatus.initial, errorMessage: null));
    }
  }

  String? _validate(Coupon coupon, double orderTotal) {
    if (!coupon.isActive) {
      return 'الكود غير فعال';
    }

    final now = DateTime.now();
    if (coupon.startDate != null && now.isBefore(coupon.startDate!)) {
      return 'الكود لم يبدأ بعد';
    }
    if (coupon.endDate != null && now.isAfter(coupon.endDate!)) {
      return 'الكود منتهي الصلاحية';
    }

    if (coupon.maxUses != null && coupon.usedCount >= coupon.maxUses!) {
      return 'الكود وصل للحد الأقصى من الاستخدام';
    }

    if (orderTotal < coupon.minOrder) {
      return 'الحد الأدنى للطلب ${coupon.minOrder.toStringAsFixed(0)} ج';
    }

    return null;
  }

  double _calculateDiscount(Coupon coupon, double orderTotal) {
    double discount;
    if (coupon.type == CouponType.percentage) {
      discount = orderTotal * (coupon.value / 100);
      if (coupon.maxDiscount != null && discount > coupon.maxDiscount!) {
        discount = coupon.maxDiscount!;
      }
    } else {
      discount = coupon.value;
    }
    if (discount > orderTotal) {
      discount = orderTotal;
    }
    return discount;
  }
}
