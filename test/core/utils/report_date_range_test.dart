import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:tarwi2a/core/utils/report_date_range.dart';

void main() {
  setUpAll(() {
    tz_data.initializeTimeZones();
  });

  group('ReportDateRange', () {
    test(
        'calculates single calendar day startInclusiveUtc and endExclusiveUtc in Africa/Cairo',
        () {
      // 2026-05-15 in Cairo
      final start = DateTime(2026, 5, 15);
      final end = DateTime(2026, 5, 15);

      final range = ReportDateRange.fromCalendarDates(
        startDate: start,
        endDate: end,
      );

      final cairo = tz.getLocation('Africa/Cairo');
      // In May, Cairo is UTC+3 (DST observed)
      final expectedStartCairo = tz.TZDateTime(cairo, 2026, 5, 15, 0, 0, 0);
      final expectedEndCairo = tz.TZDateTime(cairo, 2026, 5, 16, 0, 0, 0);

      expect(range.startInclusiveUtc, expectedStartCairo.toUtc());
      expect(range.endExclusiveUtc, expectedEndCairo.toUtc());

      // Start must be exactly 00:00:00 Cairo converted to UTC
      expect(range.startInclusiveUtc.isUtc, isTrue);
      expect(range.endExclusiveUtc.isUtc, isTrue);
      expect(range.startInclusiveUtc, DateTime.utc(2026, 5, 14, 21, 0, 0));
      expect(range.endExclusiveUtc, DateTime.utc(2026, 5, 15, 21, 0, 0));
    });

    test(
        'calculates multi-day range where endExclusiveUtc is next calendar day 00:00:00',
        () {
      final start = DateTime(2026, 5, 1);
      final end = DateTime(2026, 5, 7);

      final range = ReportDateRange.fromCalendarDates(
        startDate: start,
        endDate: end,
      );

      final cairo = tz.getLocation('Africa/Cairo');
      final expectedStartCairo = tz.TZDateTime(cairo, 2026, 5, 1, 0, 0, 0);
      final expectedEndCairo = tz.TZDateTime(cairo, 2026, 5, 8, 0, 0, 0);

      expect(range.startInclusiveUtc, expectedStartCairo.toUtc());
      expect(range.endExclusiveUtc, expectedEndCairo.toUtc());
    });

    test('handles DST transition correctly without assuming fixed 24h duration',
        () {
      // Egypt DST transition in April 2026
      final start = DateTime(2026, 4, 23);
      final end = DateTime(2026, 4, 25);

      final range = ReportDateRange.fromCalendarDates(
        startDate: start,
        endDate: end,
      );

      final cairo = tz.getLocation('Africa/Cairo');
      final expectedStartCairo = tz.TZDateTime(cairo, 2026, 4, 23, 0, 0, 0);
      final expectedEndCairo = tz.TZDateTime(cairo, 2026, 4, 26, 0, 0, 0);

      expect(range.startInclusiveUtc, expectedStartCairo.toUtc());
      expect(range.endExclusiveUtc, expectedEndCairo.toUtc());
    });

    test('handles device running in another timezone (e.g. Tokyo or UTC)', () {
      final start = DateTime.utc(2026, 5, 10, 14, 30);
      final end = DateTime.utc(2026, 5, 12, 18, 45);

      final range = ReportDateRange.fromCalendarDates(
        startDate: start,
        endDate: end,
      );

      final cairo = tz.getLocation('Africa/Cairo');
      final expectedStartCairo = tz.TZDateTime(cairo, 2026, 5, 10, 0, 0, 0);
      final expectedEndCairo = tz.TZDateTime(cairo, 2026, 5, 13, 0, 0, 0);

      expect(range.startInclusiveUtc, expectedStartCairo.toUtc());
      expect(range.endExclusiveUtc, expectedEndCairo.toUtc());
    });

    test('initialDefaultRange uses Cairo today and 7 days prior in Cairo', () {
      final nowUtc = DateTime.utc(
          2026, 5, 15, 22, 30); // It is 01:30 on May 16 in Cairo (+3)
      final range = ReportDateRange.initialDefaultRange(now: nowUtc);

      final cairo = tz.getLocation('Africa/Cairo');
      final cairoNow = tz.TZDateTime.from(nowUtc, cairo);
      expect(cairoNow.day, 16);

      // Default range is 7 days prior up to today in Cairo
      final expectedEndCairo = tz.TZDateTime(cairo, 2026, 5, 17, 0, 0, 0);
      final expectedStartCairo = tz.TZDateTime(cairo, 2026, 5, 9, 0, 0, 0);

      expect(range.startInclusiveUtc, expectedStartCairo.toUtc());
      expect(range.endExclusiveUtc, expectedEndCairo.toUtc());
    });
  });
}
