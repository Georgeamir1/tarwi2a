import 'package:flutter/material.dart';
import '../../../app/theme/app_theme.dart';

enum TimeFilter { today, week, month, quarter, custom }

class TimeFilterChips extends StatelessWidget {
  final TimeFilter selected;
  final ValueChanged<TimeFilter> onChanged;

  const TimeFilterChips({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const _labels = {
    TimeFilter.today: 'اليوم',
    TimeFilter.week: '7 أيام',
    TimeFilter.month: '30 يوم',
    TimeFilter.quarter: '90 يوم',
    TimeFilter.custom: 'مخصص',
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: TimeFilter.values.map((filter) {
          final isSelected = selected == filter;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: ChoiceChip(
              label: Text(_labels[filter]!),
              selected: isSelected,
              onSelected: (_) => onChanged(filter),
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                fontSize: 12,
              ),
              backgroundColor: AppColors.surfaceContainerHighest,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
