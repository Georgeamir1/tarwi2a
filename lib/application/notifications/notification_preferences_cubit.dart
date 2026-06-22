import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../core/logger/app_logger.dart';
import '../../domain/entities/notification_preference.dart';
import '../../domain/failures/failure.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationPreferencesCubit extends Cubit<NotificationPreferencesState> {
  final NotificationRepository _repository;

  NotificationPreferencesCubit(this._repository)
      : super(NotificationPreferencesState.initial());

  Future<void> loadPreferences(String userId) async {
    emit(state.copyWith(status: NotificationPreferencesStatus.loading));
    final result = await _repository.getPreferences(userId: userId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: NotificationPreferencesStatus.error,
        failure: failure,
      )),
      (prefs) => emit(state.copyWith(
        status: NotificationPreferencesStatus.loaded,
        preference: prefs,
      )),
    );
  }

  Future<void> updatePreference({
    required String userId,
    bool? orderUpdates,
    bool? promotions,
    bool? pushEnabled,
  }) async {
    final current = state.preference;
    final optimistic = current.copyWith(
      orderUpdates: orderUpdates ?? current.orderUpdates,
      promotions: promotions ?? current.promotions,
      pushEnabled: pushEnabled ?? current.pushEnabled,
      updatedAt: DateTime.now(),
    );
    emit(state.copyWith(
      preference: optimistic,
      status: NotificationPreferencesStatus.saving,
    ));

    final result = await _repository.updatePreferences(
      userId: userId,
      orderUpdates: orderUpdates,
      promotions: promotions,
      pushEnabled: pushEnabled,
    );

    result.fold(
      (failure) {
        appLogger.e('[NotificationPreferencesCubit] update failed',
            error: failure);
        emit(state.copyWith(
          preference: current,
          status: NotificationPreferencesStatus.error,
          failure: failure,
        ));
      },
      (saved) => emit(state.copyWith(
        preference: saved,
        status: NotificationPreferencesStatus.loaded,
      )),
    );
  }
}

enum NotificationPreferencesStatus { initial, loading, loaded, saving, error }

class NotificationPreferencesState extends Equatable {
  final NotificationPreference preference;
  final NotificationPreferencesStatus status;
  final Failure? failure;

  const NotificationPreferencesState({
    required this.preference,
    this.status = NotificationPreferencesStatus.initial,
    this.failure,
  });

  factory NotificationPreferencesState.initial() =>
      NotificationPreferencesState(
        preference: NotificationPreference(
          id: '',
          userId: '',
          orderUpdates: true,
          promotions: true,
          pushEnabled: true,
          updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
        ),
      );

  NotificationPreferencesState copyWith({
    NotificationPreference? preference,
    NotificationPreferencesStatus? status,
    Failure? failure,
  }) {
    return NotificationPreferencesState(
      preference: preference ?? this.preference,
      status: status ?? this.status,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [preference, status, failure];
}
