import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/failures/failure.dart';
import '../../../domain/repositories/category_repository.dart';

class AdminCategoriesCubit extends Cubit<AdminCategoriesState> {
  final CategoryRepository _repository;
  StreamSubscription? _subscription;

  AdminCategoriesCubit(this._repository)
      : super(AdminCategoriesState.initial());

  Future<void> loadCategories() async {
    emit(state.copyWith(status: AdminCategoriesStatus.loading));
    final result = await _repository.getAllAdmin();
    result.fold(
      (failure) => emit(state.copyWith(
        status: AdminCategoriesStatus.error,
        failure: failure,
      )),
      (categories) => emit(state.copyWith(
        status: AdminCategoriesStatus.loaded,
        categories: categories,
      )),
    );
    _listenToStream();
  }

  void _listenToStream() {
    _subscription?.cancel();
    _subscription = _repository.watchCategories().listen(
      (categories) {
        if (!isClosed) {
          emit(state.copyWith(
            categories: categories,
            status: AdminCategoriesStatus.loaded,
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
    emit(state.copyWith(status: AdminCategoriesStatus.loading));
    final result = await _repository.upsertCategory(data, id: id);
    result.fold(
      (failure) => emit(state.copyWith(
        status: AdminCategoriesStatus.error,
        failure: failure,
      )),
      (_) => loadCategories(),
    );
  }

  Future<void> toggleActive(String id, bool isActive) async {
    emit(state.copyWith(status: AdminCategoriesStatus.loading));
    final result = await _repository.toggleActive(id, isActive);
    result.fold(
      (failure) => emit(state.copyWith(
        status: AdminCategoriesStatus.error,
        failure: failure,
      )),
      (_) => loadCategories(),
    );
  }

  Future<void> deleteCategory(String id) async {
    emit(state.copyWith(status: AdminCategoriesStatus.loading));
    final result = await _repository.deleteCategory(id);
    result.fold(
      (failure) => emit(state.copyWith(
        status: AdminCategoriesStatus.error,
        failure: failure,
      )),
      (_) => loadCategories(),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

enum AdminCategoriesStatus { initial, loading, loaded, error }

class AdminCategoriesState extends Equatable {
  final List<Category> categories;
  final AdminCategoriesStatus status;
  final Failure? failure;

  const AdminCategoriesState({
    this.categories = const [],
    this.status = AdminCategoriesStatus.initial,
    this.failure,
  });

  factory AdminCategoriesState.initial() => const AdminCategoriesState();

  AdminCategoriesState copyWith({
    List<Category>? categories,
    AdminCategoriesStatus? status,
    Failure? failure,
  }) {
    return AdminCategoriesState(
      categories: categories ?? this.categories,
      status: status ?? this.status,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [categories, status, failure];
}
