import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../core/logger/app_logger.dart';
import '../../domain/entities/broadcast_log.dart';
import '../../domain/entities/broadcast_notification.dart';
import '../../domain/enums/broadcast_target.dart';
import '../../domain/enums/notification_type.dart';
import '../../domain/failures/failure.dart';
import '../../domain/repositories/broadcast_repository.dart';

class AdminBroadcastCubit extends Cubit<AdminBroadcastState> {
  final BroadcastRepository _repository;

  AdminBroadcastCubit(this._repository) : super(AdminBroadcastState.initial());

  Future<void> loadHistory() async {
    emit(state.copyWith(status: AdminBroadcastStatus.loading));
    final result = await _repository.getHistory();
    result.fold(
      (failure) => emit(state.copyWith(
        status: AdminBroadcastStatus.error,
        failure: failure,
      )),
      (history) => emit(state.copyWith(
        status: AdminBroadcastStatus.loaded,
        history: history,
      )),
    );
  }

  Future<void> previewRecipients({
    required BroadcastTargetType targetType,
    List<String> targetUserIds = const [],
  }) async {
    final result = await _repository.getRecipientsCount(
      targetType: targetType,
      targetUserIds: targetUserIds,
    );
    result.fold(
      (failure) =>
          appLogger.e('[AdminBroadcastCubit] preview failed', error: failure),
      (count) {
        emit(state.copyWith(
          previewRecipientsCount: count,
          previewTargetType: targetType,
          previewTargetUserIds: targetUserIds,
        ));
      },
    );
  }

  Future<bool> sendBroadcast({
    required String titleAr,
    required String bodyAr,
    required NotificationType type,
    required BroadcastTargetType targetType,
    List<String> targetUserIds = const [],
    String? referenceType,
    String? referenceId,
    required String senderId,
  }) async {
    if (titleAr.trim().isEmpty) {
      emit(state.copyWith(
        status: AdminBroadcastStatus.error,
        failure: const Failure.validation(message: 'العنوان مطلوب'),
      ));
      return false;
    }
    if (bodyAr.trim().isEmpty) {
      emit(state.copyWith(
        status: AdminBroadcastStatus.error,
        failure: const Failure.validation(message: 'المحتوى مطلوب'),
      ));
      return false;
    }
    if (targetType == BroadcastTargetType.specific && targetUserIds.isEmpty) {
      emit(state.copyWith(
        status: AdminBroadcastStatus.error,
        failure: const Failure.validation(
          message: 'اختر مستخدمين أو غيّر نوع الإرسال',
        ),
      ));
      return false;
    }

    emit(state.copyWith(status: AdminBroadcastStatus.sending));

    final broadcast = BroadcastNotification(
      titleAr: titleAr.trim(),
      bodyAr: bodyAr.trim(),
      type: type,
      targetType: targetType,
      targetUserIds: targetUserIds,
      referenceType: referenceType,
      referenceId: referenceId,
    );

    final result = await _repository.sendBroadcast(
      broadcast: broadcast,
      senderId: senderId,
    );

    return result.fold(
      (failure) {
        appLogger.e('[AdminBroadcastCubit] send failed', error: failure);
        emit(state.copyWith(
          status: AdminBroadcastStatus.error,
          failure: failure,
        ));
        return false;
      },
      (result) {
        appLogger.d(
          '[AdminBroadcastCubit] broadcast sent: '
          '${result.sentCount} recipients, ${result.skippedCount} skipped',
        );
        emit(state.copyWith(
          status: AdminBroadcastStatus.sent,
          lastResult: result,
        ));
        loadHistory();
        return true;
      },
    );
  }
}

enum AdminBroadcastStatus { initial, loading, loaded, sending, sent, error }

class AdminBroadcastState extends Equatable {
  final List<BroadcastLog> history;
  final int? previewRecipientsCount;
  final BroadcastTargetType? previewTargetType;
  final List<String> previewTargetUserIds;
  final BroadcastResult? lastResult;
  final AdminBroadcastStatus status;
  final Failure? failure;

  const AdminBroadcastState({
    this.history = const [],
    this.previewRecipientsCount,
    this.previewTargetType,
    this.previewTargetUserIds = const [],
    this.lastResult,
    this.status = AdminBroadcastStatus.initial,
    this.failure,
  });

  factory AdminBroadcastState.initial() => const AdminBroadcastState();

  AdminBroadcastState copyWith({
    List<BroadcastLog>? history,
    int? previewRecipientsCount,
    BroadcastTargetType? previewTargetType,
    List<String>? previewTargetUserIds,
    BroadcastResult? lastResult,
    AdminBroadcastStatus? status,
    Failure? failure,
  }) {
    return AdminBroadcastState(
      history: history ?? this.history,
      previewRecipientsCount:
          previewRecipientsCount ?? this.previewRecipientsCount,
      previewTargetType: previewTargetType ?? this.previewTargetType,
      previewTargetUserIds: previewTargetUserIds ?? this.previewTargetUserIds,
      lastResult: lastResult ?? this.lastResult,
      status: status ?? this.status,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [
        history,
        previewRecipientsCount,
        previewTargetType,
        previewTargetUserIds,
        lastResult,
        status,
        failure,
      ];
}
