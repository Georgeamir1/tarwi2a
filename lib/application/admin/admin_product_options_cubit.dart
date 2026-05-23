import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/product_option.dart';
import '../../../domain/failures/failure.dart';
import '../../../domain/repositories/product_option_repository.dart';

class AdminProductOptionsCubit extends Cubit<AdminProductOptionsState> {
  final ProductOptionRepository _repository;

  AdminProductOptionsCubit(this._repository)
      : super(AdminProductOptionsState.initial());

  Future<void> loadByProductId(String productId) async {
    emit(state.copyWith(status: AdminProductOptionsStatus.loading));
    final result = await _repository.getByProductId(productId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: AdminProductOptionsStatus.error,
        failure: failure,
      )),
      (options) => emit(state.copyWith(
        status: AdminProductOptionsStatus.loaded,
        options: options,
      )),
    );
  }

  Future<void> upsert(Map<String, dynamic> data, {String? id}) async {
    await _repository.upsert(data, id: id);
  }

  Future<void> delete(String id) async {
    await _repository.delete(id);
  }
}

enum AdminProductOptionsStatus { initial, loading, loaded, error }

class AdminProductOptionsState extends Equatable {
  final List<ProductOption> options;
  final AdminProductOptionsStatus status;
  final Failure? failure;

  const AdminProductOptionsState({
    this.options = const [],
    this.status = AdminProductOptionsStatus.initial,
    this.failure,
  });

  factory AdminProductOptionsState.initial() =>
      const AdminProductOptionsState();

  AdminProductOptionsState copyWith({
    List<ProductOption>? options,
    AdminProductOptionsStatus? status,
    Failure? failure,
  }) {
    return AdminProductOptionsState(
      options: options ?? this.options,
      status: status ?? this.status,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [options, status, failure];
}
