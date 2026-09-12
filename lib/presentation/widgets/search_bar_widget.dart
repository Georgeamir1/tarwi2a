import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';

class SearchBarWidget extends StatelessWidget {
  final String? hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final VoidCallback? onMicTap;
  final bool readOnly;

  const SearchBarWidget({
    super.key,
    this.hint,
    this.controller,
    this.onChanged,
    this.onTap,
    this.onMicTap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkCard : AppColors.surfaceContainerLow;
    final textColor =
        isDark ? AppColors.darkTextSecondary : AppColors.onSurfaceVariant;
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint ?? 'ابحث عن أكلة...',
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: textColor,
              ),
          prefixIcon: Icon(
            Icons.search,
            size: 22,
            color: textColor,
          ),
          suffixIcon: onMicTap != null
              ? IconButton(
                  onPressed: onMicTap,
                  icon: const Icon(Icons.mic_outlined, size: 22),
                  color: textColor,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }
}
