import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/coupon.dart';
import '../../../domain/failures/failure.dart';
import '../../../domain/repositories/coupon_repository.dart';

class AdminCouponsCubit extends Cubit<AdminCouponsState> {
  final CouponRepository _repository;
  StreamSubscription? _subscription;

  AdminCouponsCubit(this._repository) : super(AdminCouponsState.initial());

  Future<void> loadCoupons() async {
    emit(state.copyWith(status: AdminCouponsStatus.loading));
    final result = await _repository.getAll();
    result.fold(
      (failure) => emit(state.copyWith(
        status: AdminCouponsStatus.error,
        failure: failure,
      )),
      (coupons) => emit(state.copyWith(
        status: AdminCouponsStatus.loaded,
        coupons: coupons,
      )),
    );
    _listenToStream();
  }

  void _listenToStream() {
    _subscription?.cancel();
    _subscription = _repository.watchCoupons().listen(
      (coupons) {
        if (!isClosed) {
          emit(state.copyWith(
            coupons: coupons,
            status: AdminCouponsStatus.loaded,
          ));
        }
      },
      onError: (e) {
        if (!isClosed) {
          emit(state.copyWith(
            failure: Failure.unexpected(message: e.toString()),
          ));
        }
      },
    );
  }

  Future<void> create(Map<String, dynamic> data) async {
    await _repository.create(data);
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    await _repository.update(id, data);
  }

  Future<void> toggleActive(String id, bool isActive) async {
    await _repository.toggleActive(id, isActive);
  }

  Future<void> delete(String id) async {
    await _repository.delete(id);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

enum AdminCouponsStatus { initial, loading, loaded, error }

class AdminCouponsState extends Equatable {
  final List<Coupon> coupons;
  final AdminCouponsStatus status;
  final Failure? failure;

  const AdminCouponsState({
    this.coupons = const [],
    this.status = AdminCouponsStatus.initial,
    this.failure,
  });

  factory AdminCouponsState.initial() => const AdminCouponsState();

  AdminCouponsState copyWith({
    List<Coupon>? coupons,
    AdminCouponsStatus? status,
    Failure? failure,
  }) {
    return AdminCouponsState(
      coupons: coupons ?? this.coupons,
      status: status ?? this.status,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [coupons, status, failure];
}
