import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/business_profile.dart';
import '../../../domain/failures/failure.dart';
import '../../../domain/repositories/business_profile_repository.dart';

class AdminBusinessProfileCubit extends Cubit<AdminBusinessProfileState> {
  final BusinessProfileRepository _repository;
  StreamSubscription? _subscription;

  AdminBusinessProfileCubit(this._repository)
      : super(AdminBusinessProfileState.initial());

  Future<void> loadProfile() async {
    emit(state.copyWith(status: AdminBusinessProfileStatus.loading));
    final result = await _repository.get();
    result.fold(
      (failure) => emit(state.copyWith(
        status: AdminBusinessProfileStatus.error,
        failure: failure,
      )),
      (profile) => emit(state.copyWith(
        status: AdminBusinessProfileStatus.loaded,
        profile: profile,
      )),
    );
    _listenToStream();
  }

  void _listenToStream() {
    _subscription?.cancel();
    _subscription = _repository.watchProfile().listen(
      (profile) {
        if (!isClosed) {
          emit(state.copyWith(
            profile: profile,
            status: AdminBusinessProfileStatus.loaded,
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

  Future<void> update(Map<String, dynamic> data) async {
    final result = await _repository.update(data);
    result.fold(
      (failure) => emit(state.copyWith(
        status: AdminBusinessProfileStatus.error,
        failure: failure,
      )),
      (_) => loadProfile(),
    );
  }

  Future<void> toggleAcceptOrders(bool accept) async {
    final result = await _repository.toggleAcceptOrders(accept);
    result.fold(
      (failure) => emit(state.copyWith(
        status: AdminBusinessProfileStatus.error,
        failure: failure,
      )),
      (_) => loadProfile(),
    );
  }

  Future<void> toggleBusyMode({
    required bool isBusy,
    String? message,
  }) async {
    final result =
        await _repository.toggleBusyMode(isBusy: isBusy, message: message);
    result.fold(
      (failure) => emit(state.copyWith(
        status: AdminBusinessProfileStatus.error,
        failure: failure,
      )),
      (_) => loadProfile(),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

enum AdminBusinessProfileStatus { initial, loading, loaded, error }

class AdminBusinessProfileState extends Equatable {
  final BusinessProfile? profile;
  final AdminBusinessProfileStatus status;
  final Failure? failure;

  const AdminBusinessProfileState({
    this.profile,
    this.status = AdminBusinessProfileStatus.initial,
    this.failure,
  });

  factory AdminBusinessProfileState.initial() =>
      const AdminBusinessProfileState();

  AdminBusinessProfileState copyWith({
    BusinessProfile? profile,
    AdminBusinessProfileStatus? status,
    Failure? failure,
  }) {
    return AdminBusinessProfileState(
      profile: profile ?? this.profile,
      status: status ?? this.status,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [profile, status, failure];
}
