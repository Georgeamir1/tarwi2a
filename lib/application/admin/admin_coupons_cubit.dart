import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/logger/app_logger.dart';
import '../../../domain/entities/coupon.dart';
import '../../../domain/failures/failure.dart';
import '../../../domain/repositories/coupon_repository.dart';

class AdminCouponsCubit extends Cubit<AdminCouponsState> {
  final CouponRepository _repository;
  StreamSubscription? _subscription;

  AdminCouponsCubit(this._repository) : super(AdminCouponsState.initial());

  Future<void> loadCoupons() async {
    appLogger.i('📥 loadCoupons() called');
    emit(state.copyWith(status: AdminCouponsStatus.loading));
    final result = await _repository.getAll();
    result.fold(
      (failure) {
        appLogger.e('📥 loadCoupons() FAILED: ${failure.runtimeType}');
        emit(state.copyWith(
          status: AdminCouponsStatus.error,
          failure: failure,
        ));
      },
      (coupons) {
        appLogger
            .i('📥 loadCoupons() SUCCESS — ${coupons.length} coupons loaded');
        emit(state.copyWith(
          status: AdminCouponsStatus.loaded,
          coupons: coupons,
        ));
      },
    );
    appLogger.i('📡 subscribing to coupons realtime stream');
    _listenToStream();
  }

  void _listenToStream() {
    _subscription?.cancel();
    _subscription = _repository.watchCoupons().listen(
      (coupons) {
        if (!isClosed) {
          if (coupons.isEmpty && state.coupons.isNotEmpty) {
            return;
          }
          emit(state.copyWith(
            coupons: coupons,
            status: AdminCouponsStatus.loaded,
          ));
        }
      },
      onError: (e) {
        if (!isClosed) {
          appLogger.w('Coupons realtime stream error (kept cached data)',
              error: e);
        }
      },
    );
  }

  Future<void> create(Map<String, dynamic> data) async {
    emit(state.copyWith(status: AdminCouponsStatus.loading));
    final result = await _repository.create(data);
    if (!isClosed) {
      if (result.isRight()) {
        await loadCoupons();
      } else {
        result.fold(
          (failure) => emit(state.copyWith(
            status: AdminCouponsStatus.error,
            failure: failure,
          )),
          (_) {},
        );
      }
    }
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    emit(state.copyWith(status: AdminCouponsStatus.loading));
    final result = await _repository.update(id, data);
    if (!isClosed) {
      if (result.isRight()) {
        await loadCoupons();
      } else {
        result.fold(
          (failure) => emit(state.copyWith(
            status: AdminCouponsStatus.error,
            failure: failure,
          )),
          (_) {},
        );
      }
    }
  }

  Future<void> toggleActive(String id, bool isActive) async {
    emit(state.copyWith(status: AdminCouponsStatus.loading));
    final result = await _repository.toggleActive(id, isActive);
    if (!isClosed) {
      if (result.isRight()) {
        await loadCoupons();
      } else {
        result.fold(
          (failure) => emit(state.copyWith(
            status: AdminCouponsStatus.error,
            failure: failure,
          )),
          (_) {},
        );
      }
    }
  }

  Future<void> delete(String id) async {
    emit(state.copyWith(status: AdminCouponsStatus.loading));
    final result = await _repository.delete(id);
    if (!isClosed) {
      if (result.isRight()) {
        await loadCoupons();
      } else {
        result.fold(
          (failure) => emit(state.copyWith(
            status: AdminCouponsStatus.error,
            failure: failure,
          )),
          (_) {},
        );
      }
    }
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
