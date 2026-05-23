import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/delivery_zone.dart';
import '../../../domain/failures/failure.dart';
import '../../../domain/repositories/delivery_zone_repository.dart';

class AdminDeliveryZonesCubit extends Cubit<AdminDeliveryZonesState> {
  final DeliveryZoneRepository _repository;
  StreamSubscription? _subscription;

  AdminDeliveryZonesCubit(this._repository)
      : super(AdminDeliveryZonesState.initial());

  Future<void> loadZones() async {
    emit(state.copyWith(status: AdminDeliveryZonesStatus.loading));
    final result = await _repository.getAll();
    result.fold(
      (failure) => emit(state.copyWith(
        status: AdminDeliveryZonesStatus.error,
        failure: failure,
      )),
      (zones) => emit(state.copyWith(
        status: AdminDeliveryZonesStatus.loaded,
        zones: zones,
      )),
    );
    _listenToStream();
  }

  void _listenToStream() {
    _subscription?.cancel();
    _subscription = _repository.watchDeliveryZones().listen(
      (zones) {
        if (!isClosed) {
          emit(state.copyWith(
            zones: zones,
            status: AdminDeliveryZonesStatus.loaded,
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

  Future<void> upsert(Map<String, dynamic> data, {String? id}) async {
    await _repository.upsert(data, id: id);
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
