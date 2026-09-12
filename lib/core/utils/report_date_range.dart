import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class ReportDateRange {
  final DateTime startInclusiveUtc;
  final DateTime endExclusiveUtc;

  const ReportDateRange({
    required this.startInclusiveUtc,
    required this.endExclusiveUtc,
  });

  static bool _timeZonesInitialized = false;

  static void ensureInitialized() {
    if (!_timeZonesInitialized) {
      tz_data.initializeTimeZones();
      _timeZonesInitialized = true;
    }
  }

  static tz.Location get cairoLocation {
    ensureInitialized();
    return tz.getLocation('Africa/Cairo');
  }

  /// Constructs a UTC boundary range from calendar start and end dates in Africa/Cairo.
  ///
  /// The [startDate] midnight (00:00:00) in Cairo becomes [startInclusiveUtc].
  /// The day after [endDate] midnight (00:00:00) in Cairo becomes [endExclusiveUtc].
  factory ReportDateRange.fromCalendarDates({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    ensureInitialized();
    final cairo = cairoLocation;

    // Use calendar components (year, month, day) regardless of local device time/timezone
    final startCairo =
        tz.TZDateTime(cairo, startDate.year, startDate.month, startDate.day);
    // Next calendar day in Cairo handles DST transition without adding fixed 24h Duration
    final endNextDayCairo =
        tz.TZDateTime(cairo, endDate.year, endDate.month, endDate.day + 1);

    return ReportDateRange(
      startInclusiveUtc: startCairo.toUtc(),
      endExclusiveUtc: endNextDayCairo.toUtc(),
    );
  }

  /// Calculates the default 7-day range in Africa/Cairo relative to [now].
  factory ReportDateRange.initialDefaultRange({DateTime? now}) {
    ensureInitialized();
    final cairo = cairoLocation;
    final cairoNow = tz.TZDateTime.from(now ?? DateTime.now(), cairo);

    final sevenDaysAgoCairo =
        tz.TZDateTime(cairo, cairoNow.year, cairoNow.month, cairoNow.day - 7);
    final tomorrowCairo =
        tz.TZDateTime(cairo, cairoNow.year, cairoNow.month, cairoNow.day + 1);

    return ReportDateRange(
      startInclusiveUtc: sevenDaysAgoCairo.toUtc(),
      endExclusiveUtc: tomorrowCairo.toUtc(),
    );
  }

  /// Returns the current calendar date in Africa/Cairo.
  static DateTime nowInCairo({DateTime? now}) {
    ensureInitialized();
    final cairo = cairoLocation;
    final cairoNow = tz.TZDateTime.from(now ?? DateTime.now(), cairo);
    return DateTime(cairoNow.year, cairoNow.month, cairoNow.day);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportDateRange &&
          runtimeType == other.runtimeType &&
          startInclusiveUtc == other.startInclusiveUtc &&
          endExclusiveUtc == other.endExclusiveUtc;

  @override
  int get hashCode => startInclusiveUtc.hashCode ^ endExclusiveUtc.hashCode;

  @override
  String toString() =>
      'ReportDateRange(startInclusiveUtc: $startInclusiveUtc, endExclusiveUtc: $endExclusiveUtc)';
}
