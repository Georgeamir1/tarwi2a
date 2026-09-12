import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tarwi2a/application/admin/admin_reports_cubit.dart';
import 'package:tarwi2a/core/utils/report_date_range.dart';
import '../../helpers/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockReportRepository mockRepo;
  late AdminReportsCubit cubit;

  setUpAll(() {
    registerFallbackValue(testServerFailure);
    registerFallbackValue(testReportData);
    registerFallbackValue(DateTime.now());
  });

  setUp(() {
    mockRepo = MockReportRepository();
  });

  group('AdminReportsCubit', () {
    test('initial state has correct date range based on Cairo today', () {
      cubit = AdminReportsCubit(mockRepo);
      expect(cubit.state.status, AdminReportsStatus.initial);
      expect(cubit.state.data, isNull);
      final cairoToday = ReportDateRange.nowInCairo();
      expect(cubit.state.endDate, cairoToday);
      expect(cubit.state.startDate.day,
          cairoToday.subtract(const Duration(days: 7)).day);
    });

    test(
        'loadReports converts calendar dates to Cairo UTC boundaries before calling repository',
        () async {
      when(() => mockRepo.getReports(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenAnswer((_) async => right(testReportData));

      cubit = AdminReportsCubit(mockRepo);
      final start = DateTime(2026, 5, 1);
      final end = DateTime(2026, 5, 20);
      final expectedRange = ReportDateRange.fromCalendarDates(
        startDate: start,
        endDate: end,
      );

      await cubit.loadReports(
        startDate: start,
        endDate: end,
      );

      expect(cubit.state.status, AdminReportsStatus.loaded);
      expect(cubit.state.data!.totalRevenue, 15000.0);
      expect(cubit.state.data!.totalOrders, 85);
      verify(() => mockRepo.getReports(
            startDate: expectedRange.startInclusiveUtc,
            endDate: expectedRange.endExclusiveUtc,
          )).called(1);
    });

    test('loadReports emits error on failure', () async {
      when(() => mockRepo.getReports(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenAnswer((_) async => left(testServerFailure));

      cubit = AdminReportsCubit(mockRepo);
      await cubit.loadReports(
        startDate: DateTime(2026, 5, 1),
        endDate: DateTime(2026, 5, 20),
      );

      expect(cubit.state.status, AdminReportsStatus.error);
      expect(cubit.state.failure, testServerFailure);
    });

    test('updateDateRange triggers reload with Cairo UTC range', () async {
      when(() => mockRepo.getReports(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenAnswer((_) async => right(testReportData));

      cubit = AdminReportsCubit(mockRepo);
      final newStart = DateTime(2026, 5, 10);
      final newEnd = DateTime(2026, 5, 17);
      final expectedRange = ReportDateRange.fromCalendarDates(
        startDate: newStart,
        endDate: newEnd,
      );

      cubit.updateDateRange(newStart, newEnd);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(cubit.state.startDate, newStart);
      expect(cubit.state.endDate, newEnd);
      verify(() => mockRepo.getReports(
            startDate: expectedRange.startInclusiveUtc,
            endDate: expectedRange.endExclusiveUtc,
          )).called(1);
    });
  });
}
