import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/failures/failure.dart';
import '../../../domain/repositories/category_repository.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  final CategoryRepository _repository;

  CategoriesCubit(this._repository) : super(CategoriesState.initial());

  Future<void> loadCategories() async {
    emit(state.copyWith(status: CategoriesStatus.loading));
    final result = await _repository.getCategories();
    result.fold(
      (failure) => emit(state.copyWith(
        status: CategoriesStatus.error,
        failure: failure,
      )),
      (categories) => emit(state.copyWith(
        status: CategoriesStatus.loaded,
        categories: categories,
      )),
    );
  }
}

enum CategoriesStatus { initial, loading, loaded, error }

class CategoriesState extends Equatable {
  final List<Category> categories;
  final CategoriesStatus status;
  final Failure? failure;

  const CategoriesState({
    this.categories = const [],
    this.status = CategoriesStatus.initial,
    this.failure,
  });

  factory CategoriesState.initial() => const CategoriesState();

  CategoriesState copyWith({
    List<Category>? categories,
    CategoriesStatus? status,
    Failure? failure,
  }) {
    return CategoriesState(
      categories: categories ?? this.categories,
      status: status ?? this.status,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [categories, status, failure];
}
