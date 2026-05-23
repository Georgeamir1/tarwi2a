import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';
import '../../domain/entities/business_profile.dart';

class OpeningHoursEditor extends StatefulWidget {
  final Map<String, OpeningPeriod> hours;
  final ValueChanged<Map<String, OpeningPeriod>> onChanged;

  const OpeningHoursEditor({
    super.key,
    required this.hours,
    required this.onChanged,
  });

  @override
  State<OpeningHoursEditor> createState() => _OpeningHoursEditorState();
}

class _OpeningHoursEditorState extends State<OpeningHoursEditor> {
  static const _dayLabels = {
    'saturday': 'السبت',
    'sunday': 'الأحد',
    'monday': 'الإثنين',
    'tuesday': 'الثلاثاء',
    'wednesday': 'الأربعاء',
    'thursday': 'الخميس',
    'friday': 'الجمعة',
  };

  late Map<String, OpeningPeriod> _hours;

  @override
  void initState() {
    super.initState();
    _hours = Map.from(widget.hours);
    for (final day in _dayLabels.keys) {
      _hours.putIfAbsent(
        day,
        () => const OpeningPeriod(open: '10:00', close: '22:00'),
      );
    }
  }

  void _updateOpen(String day, String value) {
    setState(() {
      _hours[day] = _hours[day]!.copyWith(open: value);
    });
    widget.onChanged(_hours);
  }

  void _updateClose(String day, String value) {
    setState(() {
      _hours[day] = _hours[day]!.copyWith(close: value);
    });
    widget.onChanged(_hours);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                'اليوم',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ),
            Expanded(
              child: Text(
                'الفتح',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ),
            Expanded(
              child: Text(
                'الإغلاق',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ),
          ],
        ),
        AppSpacing.gapH8,
        ..._dayLabels.entries.map((entry) {
          final period = _hours[entry.key]!;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    entry.value,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Expanded(
                  child: _TimeInput(
                    value: period.open,
                    onChanged: (v) => _updateOpen(entry.key, v),
                  ),
                ),
                AppSpacing.gapW8,
                Expanded(
                  child: _TimeInput(
                    value: period.close,
                    onChanged: (v) => _updateClose(entry.key, v),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _TimeInput extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _TimeInput({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(
            hour: int.tryParse(value.split(':')[0]) ?? 10,
            minute: int.tryParse(value.split(':')[1]) ?? 0,
          ),
        );
        if (time != null) {
          onChanged(
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.outlineVariant),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Text(
          value,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
