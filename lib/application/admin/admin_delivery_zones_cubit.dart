import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/logger/app_logger.dart';
import '../../../domain/entities/delivery_zone.dart';
import '../../../domain/failures/failure.dart';
import '../../../domain/repositories/delivery_zone_repository.dart';

class AdminDeliveryZonesCubit extends Cubit<AdminDeliveryZonesState> {
  final DeliveryZoneRepository _repository;
  StreamSubscription? _subscription;

  AdminDeliveryZonesCubit(this._repository)
      : super(AdminDeliveryZonesState.initial());

  Future<void> loadZones() async {
    appLogger.i('📥 loadZones() called');
    emit(state.copyWith(status: AdminDeliveryZonesStatus.loading));
    final result = await _repository.getAll();
    result.fold(
      (failure) {
        appLogger.e('📥 loadZones() FAILED: ${failure.runtimeType}');
        emit(state.copyWith(
          status: AdminDeliveryZonesStatus.error,
          failure: failure,
        ));
      },
      (zones) {
        appLogger.i('📥 loadZones() SUCCESS — ${zones.length} zones loaded');
        emit(state.copyWith(
          status: AdminDeliveryZonesStatus.loaded,
          zones: zones,
        ));
      },
    );
    appLogger.i('📡 subscribing to zones realtime stream');
    _listenToStream();
  }

  void _listenToStream() {
    _subscription?.cancel();
    _subscription = _repository.watchDeliveryZones().listen(
      (zones) {
        if (!isClosed) {
          if (zones.isEmpty && state.zones.isNotEmpty) {
            return;
          }
          emit(state.copyWith(
            zones: zones,
            status: AdminDeliveryZonesStatus.loaded,
          ));
        }
      },
      onError: (e) {
        if (!isClosed) {
          appLogger.w('Delivery zones realtime stream error (kept cached data)',
              error: e);
        }
      },
    );
  }

  Future<void> upsert(Map<String, dynamic> data, {String? id}) async {
    emit(state.copyWith(status: AdminDeliveryZonesStatus.loading));
    final result = await _repository.upsert(data, id: id);
    if (!isClosed) {
      if (result.isRight()) {
        await loadZones();
      } else {
        result.fold(
          (failure) => emit(state.copyWith(
            status: AdminDeliveryZonesStatus.error,
            failure: failure,
          )),
          (_) {},
        );
      }
    }
  }

  Future<void> toggleActive(String id, bool isActive) async {
    emit(state.copyWith(status: AdminDeliveryZonesStatus.loading));
    final result = await _repository.toggleActive(id, isActive);
    if (!isClosed) {
      if (result.isRight()) {
        await loadZones();
      } else {
        result.fold(
          (failure) => emit(state.copyWith(
            status: AdminDeliveryZonesStatus.error,
            failure: failure,
          )),
          (_) {},
        );
      }
    }
  }

  Future<void> delete(String id) async {
    emit(state.copyWith(status: AdminDeliveryZonesStatus.loading));
    final result = await _repository.delete(id);
    if (!isClosed) {
      if (result.isRight()) {
        await loadZones();
      } else {
        result.fold(
          (failure) => emit(state.copyWith(
            status: AdminDeliveryZonesStatus.error,
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

enum AdminDeliveryZonesStatus { initial, loading, loaded, error }

class AdminDeliveryZonesState extends Equatable {
  final List<DeliveryZone> zones;
  final AdminDeliveryZonesStatus status;
  final Failure? failure;

  const AdminDeliveryZonesState({
    this.zones = const [],
    this.status = AdminDeliveryZonesStatus.initial,
    this.failure,
  });

  factory AdminDeliveryZonesState.initial() => const AdminDeliveryZonesState();

  AdminDeliveryZonesState copyWith({
    List<DeliveryZone>? zones,
    AdminDeliveryZonesStatus? status,
    Failure? failure,
  }) {
    return AdminDeliveryZonesState(
      zones: zones ?? this.zones,
      status: status ?? this.status,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [zones, status, failure];
}
