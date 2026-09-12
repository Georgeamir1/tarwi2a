import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import '../../../domain/entities/address.dart';
import '../../../domain/failures/failure.dart';
import '../../../domain/repositories/address_repository.dart';
import '../../../core/logger/app_logger.dart';

class AddressCubit extends Cubit<AddressState> {
  final AddressRepository _addressRepository;

  AddressCubit(this._addressRepository) : super(AddressState.initial());

  Future<void> loadAddresses(String userId) async {
    if (isClosed) return;
    emit(state.copyWith(status: AddressStatus.loading));
    final result = await _addressRepository.getAddresses(userId);
    if (!isClosed) {
      result.fold(
        (failure) => emit(state.copyWith(
          status: AddressStatus.error,
          failure: failure,
        )),
        (addresses) => emit(state.copyWith(
          status: AddressStatus.loaded,
          addresses: addresses,
        )),
      );
    }
  }

  Future<Either<Failure, void>> createAddress(
      String userId, Map<String, dynamic> data) async {
    if (!isClosed) emit(state.copyWith(status: AddressStatus.saving));
    final payload = Map<String, dynamic>.from(data);
    payload['user_id'] = userId;
    final result = await _addressRepository.createAddress(payload);
    return result.fold(
      (failure) {
        if (!isClosed) {
          emit(state.copyWith(
            status: AddressStatus.error,
            failure: failure,
          ));
        }
        return left(failure);
      },
      (_) async {
        appLogger.d('[AddressCubit] address created, reloading');
        if (!isClosed) {
          await loadAddresses(userId);
        }
        return right(null);
      },
    );
  }

  Future<Either<Failure, void>> updateAddress(
      String id, Map<String, dynamic> data, String userId) async {
    if (!isClosed) emit(state.copyWith(status: AddressStatus.saving));
    final result = await _addressRepository.updateAddress(id, data);
    return result.fold(
      (failure) {
        if (!isClosed) {
          emit(state.copyWith(
            status: AddressStatus.error,
            failure: failure,
          ));
        }
        return left(failure);
      },
      (_) async {
        appLogger.d('[AddressCubit] address updated, reloading');
        if (!isClosed) {
          await loadAddresses(userId);
        }
        return right(null);
      },
    );
  }

  Future<void> deleteAddress(String id, String userId) async {
    if (!isClosed) emit(state.copyWith(status: AddressStatus.saving));
    final result = await _addressRepository.deleteAddress(id);
    if (!isClosed) {
      result.fold(
        (failure) => emit(state.copyWith(
          status: AddressStatus.error,
          failure: failure,
        )),
        (_) async {
          appLogger.d('[AddressCubit] address deleted, reloading');
          if (!isClosed) {
            await loadAddresses(userId);
          }
        },
      );
    }
  }

  Future<void> setDefault(String id, String userId) async {
    final result = await _addressRepository.setDefault(id, userId);
    if (!isClosed) {
      result.fold(
        (failure) => emit(state.copyWith(failure: failure)),
        (_) async {
          appLogger.d('[AddressCubit] default set, reloading');
          if (!isClosed) {
            await loadAddresses(userId);
          }
        },
      );
    }
  }
}

enum AddressStatus { initial, loading, loaded, saving, error }

class AddressState extends Equatable {
  final List<Address> addresses;
  final AddressStatus status;
  final Failure? failure;

  const AddressState({
    this.addresses = const [],
    this.status = AddressStatus.initial,
    this.failure,
  });

  factory AddressState.initial() => const AddressState();

  AddressState copyWith({
    List<Address>? addresses,
    AddressStatus? status,
    Failure? failure,
  }) {
    return AddressState(
      addresses: addresses ?? this.addresses,
      status: status ?? this.status,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [addresses, status, failure];
}
