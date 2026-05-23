import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_theme.dart';

enum TopBarVariant { withBack, withMenu, transparent }

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final TopBarVariant variant;
  final List<Widget>? actions;
  final VoidCallback? onBack;
  final VoidCallback? onMenu;
  final Widget? leading;

  const AppTopBar({
    super.key,
    required this.title,
    this.variant = TopBarVariant.withBack,
    this.actions,
    this.onBack,
    this.onMenu,
    this.leading,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    if (variant == TopBarVariant.transparent) {
      return AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        leading: leading ??
            (onBack != null
                ? IconButton(
                    onPressed: onBack,
                    icon: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.darkSurface : AppColors.surface).withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, size: 18),
                    ),
                  )
                : null),
        actions: actions,
        title: const SizedBox.shrink(),
      );
    }

    return AppBar(
      backgroundColor: isDark
          ? AppColors.darkSurface.withValues(alpha: 0.8)
          : AppColors.surface.withValues(alpha: 0.8),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      systemOverlayStyle: isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      leading: variant == TopBarVariant.withBack
          ? leading ??
              IconButton(
                onPressed: onBack ?? () {
                  if (Navigator.of(context).canPop()) {
                    context.pop();
                  }
                },
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              )
          : variant == TopBarVariant.withMenu
              ? leading ??
                  IconButton(
                    onPressed: onMenu,
                    icon: const Icon(Icons.menu, size: 24),
                  )
              : null,
      title: Text(
        title,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: actions,
    );
  }
}
