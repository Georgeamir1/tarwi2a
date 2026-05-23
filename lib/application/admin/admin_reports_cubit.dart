import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/logger/app_logger.dart';
import '../../../domain/repositories/report_repository.dart';
import '../../../domain/failures/failure.dart';

class AdminReportsCubit extends Cubit<AdminReportsState>
    with WidgetsBindingObserver {
  final ReportRepository _repository;
  Timer? _refreshTimer;
  bool _isPaused = false;

  AdminReportsCubit(this._repository) : super(AdminReportsState.initial()) {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pauseRefreshTimer();
    } else if (state == AppLifecycleState.resumed) {
      _resumeRefreshTimer();
    }
  }

  void _pauseRefreshTimer() {
    _isPaused = true;
    appLogger.d('[AdminReportsCubit] Timer paused (app backgrounded)');
  }

  void _resumeRefreshTimer() {
    if (_isPaused) {
      _isPaused = false;
      appLogger.d('[AdminReportsCubit] Timer resumed (app foregrounded)');
      loadReports(startDate: state.startDate, endDate: state.endDate);
    }
  }

  Future<void> loadReports({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    emit(state.copyWith(status: AdminReportsStatus.loading));
    final result = await _repository.getReports(
      startDate: startDate,
      endDate: endDate,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: AdminReportsStatus.error,
        failure: failure,
      )),
      (data) => emit(state.copyWith(
        status: AdminReportsStatus.loaded,
        data: data,
      )),
    );
    _startRefreshTimer(startDate, endDate);
  }

  void _startRefreshTimer(DateTime startDate, DateTime endDate) {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) {
        if (!_isPaused) {
          _loadReportsSilently(startDate, endDate);
        }
      },
    );
  }

  Future<void> _loadReportsSilently(
      DateTime startDate, DateTime endDate) async {
    if (_isPaused) return;
    final result = await _repository.getReports(
      startDate: startDate,
      endDate: endDate,
    );
    result.fold(
      (_) {},
      (data) {
        if (!isClosed && !_isPaused) {
          emit(state.copyWith(data: data));
        }
      },
    );
  }

  void updateDateRange(DateTime start, DateTime end) {
    emit(state.copyWith(startDate: start, endDate: end));
    loadReports(startDate: start, endDate: end);
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    return super.close();
  }
}

enum AdminReportsStatus { initial, loading, loaded, error }

class AdminReportsState extends Equatable {
  final ReportData? data;
  final AdminReportsStatus status;
  final Failure? failure;
  final DateTime startDate;
  final DateTime endDate;

  const AdminReportsState({
    this.data,
    this.status = AdminReportsStatus.initial,
    this.failure,
    required this.startDate,
    required this.endDate,
  });

  factory AdminReportsState.initial() {
    final now = DateTime.now();
    return AdminReportsState(
      startDate: now.subtract(const Duration(days: 7)),
      endDate: now,
    );
  }

  AdminReportsState copyWith({
    ReportData? data,
    AdminReportsStatus? status,
    Failure? failure,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return AdminReportsState(
      data: data ?? this.data,
      status: status ?? this.status,
      failure: failure,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  List<Object?> get props => [data, status, failure, startDate, endDate];
}
