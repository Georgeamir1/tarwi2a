import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Levantine Clarity Design System
/// Inspired by iOS HIG with Arabic hospitality warmth
/// Primary: Saffron (#855300) - Action
/// Secondary: Zatar Green (#48654f) - Structure
/// Tertiary: Sky Blue (#00658b) - Accent
class AppColors {
  // Primary - Cherry Red (Action & appetite)
  static const primary = Color(0xFFE02B2B);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFFFFE3E3);
  static const onPrimaryContainer = Color(0xFF8B1E1E);
  static const primaryFixed = Color(0xFFFFDAD6);
  static const primaryFixedDim = Color(0xFFFFB4AB);
  static const onPrimaryFixed = Color(0xFF410002);
  static const onPrimaryFixedVariant = Color(0xFF93000A);
  static const inversePrimary = Color(0xFFFFB4AB);

  // Secondary - Warm Cocoa (Structure & balance)
  static const secondary = Color(0xFF5C4E4D);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFF0E3E2);
  static const onSecondaryContainer = Color(0xFF2C2120);
  static const secondaryFixed = Color(0xFFF0E3E2);
  static const secondaryFixedDim = Color(0xFFD3C2C0);
  static const onSecondaryFixed = Color(0xFF1A1110);
  static const onSecondaryFixedVariant = Color(0xFF3F3332);

  // Tertiary - Amber Gold (Accent & hospitality)
  static const tertiary = Color(0xFFC68B59);
  static const onTertiary = Color(0xFFFFFFFF);
  static const tertiaryContainer = Color(0xFFFCECDD);
  static const onTertiaryContainer = Color(0xFF513116);
  static const tertiaryFixed = Color(0xFFFCECDD);
  static const tertiaryFixedDim = Color(0xFFDFB897);
  static const onTertiaryFixed = Color(0xFF271300);
  static const onTertiaryFixedVariant = Color(0xFF452409);

  // Error
  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);

  // Surfaces (Warm Rose White theme)
  static const background = Color(0xFFFDF8F7);
  static const onBackground = Color(0xFF2C2120);
  static const surface = Color(0xFFFFFFFF);
  static const onSurface = Color(0xFF2C2120);
  static const onSurfaceVariant = Color(0xFFE02B2B);
  static const inverseSurface = Color(0xFF3B302F);
  static const inverseOnSurface = Color(0xFFFAF0EF);
  static const surfaceVariant = Color(0xFFF5E7E5);
  static const surfaceDim = Color(0xFFFCF5F4);
  static const surfaceBright = Color(0xFFFDF8F7);
  static const surfaceTint = Color(0xFFE02B2B);

  // Surface Containers (Material 3 style)
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFFCF5F4);
  static const surfaceContainer = Color(0xFFF6ECEB);
  static const surfaceContainerHigh = Color(0xFFEFE2E0);
  static const surfaceContainerHighest = Color(0xFFE7D8D6);

  // Outlines
  static const outline = Color(0xFF8C7B79);
  static const outlineVariant = Color(0xFFE0D2D0);

  // Legacy aliases for backward compatibility
  static const textPrimary = onSurface;
  static const textSecondary = onSurfaceVariant;
  static const divider = outlineVariant;
  static const borderLight = Color(0x1F000000);
  static const shadowSubtle = Color(0x0A000000);

  // Status Colors
  static const statusPending = Color(0xFFE89820);
  static const statusConfirmed = Color(0xFF3B82C4);
  static const statusPreparing = Color(0xFF8B5CF6);
  static const statusReady = Color(0xFF2D8C5E);
  static const statusDelivered = Color(0xFF22C55E);
  static const statusCancelled = Color(0xFFD14334);

  // Legacy compatibility aliases (deprecated, use semantic names above)
  static const warning = Color(0xFFE89820);
  static const success = Color(0xFF2D8C5E);
  static const grey100 = Color(0xFFF5ECEB);
  static const grey200 = Color(0xFFEFE2E0);
  static const grey300 = Color(0xFFE7D8D6);
  static const grey400 = Color(0xFFC7B4B2);
  static const grey500 = Color(0xFF9C8A88);
  static const primaryLight = Color(0x14E02B2B);
  static const primaryShadow = Color(0x33E02B2B);
  static const primaryDark = Color(0xFFB81E1E);
  static const secondaryShadow = Color(0x335C4E4D);
  static const errorLight = Color(0x18D14334);

  // Dark Theme
  static const darkBackground = Color(0xFF1F1615);
  static const darkSurface = Color(0xFF2C2120);
  static const darkCard = Color(0xFF382B2A);
  static const darkTextPrimary = Color(0xFFF5E0DF);
  static const darkTextSecondary = Color(0xFFC7B4B2);
  static const darkDivider = Color(0xFF504140);

  static Color statusColor(String status) {
    switch (status) {
      case 'pending':
        return statusPending;
      case 'confirmed':
        return statusConfirmed;
      case 'preparing':
        return statusPreparing;
      case 'ready':
        return statusReady;
      case 'delivered':
        return statusDelivered;
      case 'cancelled':
        return statusCancelled;
      default:
        return Colors.grey;
    }
  }
}

/// Spacing tokens based on 8px grid
class AppSpacing {
  static const double unit = 8;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  static const gapH2 = SizedBox(height: 2);
  static const gapH4 = SizedBox(height: 4);
  static const gapH6 = SizedBox(height: 6);
  static const gapH8 = SizedBox(height: 8);
  static const gapH10 = SizedBox(height: 10);
  static const gapH12 = SizedBox(height: 12);
  static const gapH16 = SizedBox(height: 16);
  static const gapH20 = SizedBox(height: 20);
  static const gapH24 = SizedBox(height: 24);
  static const gapH32 = SizedBox(height: 32);
  static const gapH48 = SizedBox(height: 48);

  static const gapW8 = SizedBox(width: 8);
  static const gapW12 = SizedBox(width: 12);
  static const gapW16 = SizedBox(width: 16);

  static const screenPadding = EdgeInsets.symmetric(horizontal: 16);
  static const cardPadding = EdgeInsets.all(16);
  static const sectionPadding = EdgeInsets.all(24);
}

/// Shape tokens
class AppRadius {
  static const double sm = 4;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double xxl = 24;
  static const double full = 9999;

  static BorderRadius get smAll => BorderRadius.circular(sm);
  static BorderRadius get mdAll => BorderRadius.circular(md);
  static BorderRadius get lgAll => BorderRadius.circular(lg);
  static BorderRadius get xlAll => BorderRadius.circular(xl);
  static BorderRadius get xxlAll => BorderRadius.circular(xxl);
}

/// Typography tokens
class AppTypography {
  static const _fontFamily = 'Cairo';

  // Large Title - Splash screen, hero headlines
  static const largeTitle = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    height: 41 / 34,
    letterSpacing: 0.37,
    color: AppColors.onSurface,
  );

  // Headline - Screen titles, section headers
  static const headline = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 22 / 17,
    letterSpacing: -0.41,
    color: AppColors.onSurface,
  );

  // Body - Primary reading text
  static const body = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 22 / 17,
    letterSpacing: -0.41,
    color: AppColors.onSurface,
  );

  // Callout - Emphasized body, form labels
  static const callout = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 21 / 16,
    letterSpacing: -0.32,
    color: AppColors.onSurface,
  );

  // Subheadline - Secondary labels, metadata
  static const subheadline = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 20 / 15,
    letterSpacing: -0.24,
    color: AppColors.onSurfaceVariant,
  );

  // Footnote - Tertiary info, timestamps
  static const footnote = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 18 / 13,
    letterSpacing: -0.08,
    color: AppColors.onSurfaceVariant,
  );

  // Caption - Badges, small labels
  static const caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
    letterSpacing: 0,
    color: AppColors.onSurfaceVariant,
  );
}

/// Shadow tokens
class AppShadows {
  static const card = BoxShadow(
    color: Color(0x0A000000),
    blurRadius: 8,
    offset: Offset(0, 2),
  );

  static const elevated = BoxShadow(
    color: Color(0x14000000),
    blurRadius: 16,
    offset: Offset(0, 4),
  );

  static const floating = BoxShadow(
    color: Color(0x1F000000),
    blurRadius: 32,
    offset: Offset(0, 8),
  );

  static const bottomNav = BoxShadow(
    color: Color(0x0D000000),
    blurRadius: 12,
    offset: Offset(0, -4),
  );
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onTertiaryContainer,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        surfaceContainerHighest: AppColors.surfaceContainerHighest,
        surfaceContainerHigh: AppColors.surfaceContainerHigh,
        surfaceContainer: AppColors.surfaceContainer,
        surfaceContainerLow: AppColors.surfaceContainerLow,
        surfaceContainerLowest: AppColors.surfaceContainerLowest,
        surfaceBright: AppColors.surfaceBright,
        surfaceDim: AppColors.surfaceDim,
        surfaceTint: AppColors.surfaceTint,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
        inverseSurface: AppColors.inverseSurface,
        inversePrimary: AppColors.inversePrimary,
        shadow: Color(0xFF000000),
        scrim: Color(0xFF000000),
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Cairo',
      textTheme: TextTheme(
        displayLarge: AppTypography.largeTitle,
        headlineLarge: AppTypography.largeTitle.copyWith(fontSize: 32),
        headlineMedium: AppTypography.headline
            .copyWith(fontSize: 24, fontWeight: FontWeight.w700),
        headlineSmall: AppTypography.headline,
        titleLarge: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
        titleMedium:
            AppTypography.callout.copyWith(fontWeight: FontWeight.w600),
        titleSmall:
            AppTypography.subheadline.copyWith(fontWeight: FontWeight.w600),
        bodyLarge: AppTypography.body,
        bodyMedium: AppTypography.callout,
        bodySmall: AppTypography.subheadline,
        labelLarge:
            AppTypography.footnote.copyWith(fontWeight: FontWeight.w600),
        labelMedium: AppTypography.footnote,
        labelSmall: AppTypography.caption,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface.withValues(alpha: 0.8),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: const IconThemeData(color: AppColors.onSurface),
        titleTextStyle:
            AppTypography.headline.copyWith(fontWeight: FontWeight.w700),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          textStyle: AppTypography.headline.copyWith(
            color: AppColors.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.outline),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          textStyle:
              AppTypography.headline.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle:
              AppTypography.subheadline.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle:
            AppTypography.body.copyWith(color: AppColors.onSurfaceVariant),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: const BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceContainerLow,
        selectedColor: AppColors.primary,
        labelStyle: AppTypography.subheadline,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        side: const BorderSide(color: AppColors.outlineVariant),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface.withValues(alpha: 0.9),
        elevation: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.inverseSurface,
        contentTextStyle:
            AppTypography.body.copyWith(color: AppColors.inverseOnSurface),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        titleTextStyle: AppTypography.headline.copyWith(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.onSurfaceVariant,
        indicatorColor: AppColors.primary,
        labelStyle: AppTypography.subheadline.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTypography.subheadline,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.outlineVariant;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.onSurfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary.withValues(alpha: 0.5);
          }
          return AppColors.surfaceContainerHighest;
        }),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.onSurfaceVariant;
        }),
      ),
      listTileTheme: ListTileThemeData(
        tileColor: AppColors.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        titleTextStyle: AppTypography.body.copyWith(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w600,
        ),
        subtitleTextStyle: AppTypography.subheadline.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(
          AppColors.outline.withValues(alpha: 0.6),
        ),
        radius: const Radius.circular(AppRadius.full),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.inverseSurface,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: AppTypography.caption.copyWith(
          color: AppColors.inverseOnSurface,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        textStyle: AppTypography.body.copyWith(
          color: AppColors.onSurface,
        ),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.inversePrimary,
        onPrimary: AppColors.onPrimaryFixed,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onTertiaryContainer,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        surfaceContainerHighest: Color(0xFF3D3830),
        surfaceContainerHigh: Color(0xFF38332C),
        surfaceContainer: Color(0xFF2F2A25),
        surfaceContainerLow: Color(0xFF24211D),
        surfaceContainerLowest: Color(0xFF1A1814),
        surfaceBright: Color(0xFF3D3830),
        surfaceDim: Color(0xFF1A1814),
        surfaceTint: AppColors.inversePrimary,
        outline: AppColors.darkDivider,
        outlineVariant: AppColors.darkDivider,
        inverseSurface: AppColors.surface,
        inversePrimary: AppColors.primary,
        shadow: Color(0xFF000000),
        scrim: Color(0xFF000000),
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      fontFamily: 'Cairo',
      textTheme: TextTheme(
        displayLarge:
            AppTypography.largeTitle.copyWith(color: AppColors.darkTextPrimary),
        headlineLarge: AppTypography.largeTitle
            .copyWith(fontSize: 32, color: AppColors.darkTextPrimary),
        headlineMedium: AppTypography.headline.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.darkTextPrimary),
        headlineSmall:
            AppTypography.headline.copyWith(color: AppColors.darkTextPrimary),
        titleLarge: AppTypography.body.copyWith(
            fontWeight: FontWeight.w600, color: AppColors.darkTextPrimary),
        titleMedium: AppTypography.callout.copyWith(
            fontWeight: FontWeight.w600, color: AppColors.darkTextPrimary),
        titleSmall: AppTypography.subheadline.copyWith(
            fontWeight: FontWeight.w600, color: AppColors.darkTextSecondary),
        bodyLarge:
            AppTypography.body.copyWith(color: AppColors.darkTextPrimary),
        bodyMedium:
            AppTypography.callout.copyWith(color: AppColors.darkTextPrimary),
        bodySmall: AppTypography.subheadline
            .copyWith(color: AppColors.darkTextSecondary),
        labelLarge: AppTypography.footnote.copyWith(
            fontWeight: FontWeight.w600, color: AppColors.darkTextPrimary),
        labelMedium:
            AppTypography.footnote.copyWith(color: AppColors.darkTextSecondary),
        labelSmall:
            AppTypography.caption.copyWith(color: AppColors.darkTextSecondary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface.withValues(alpha: 0.8),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
        titleTextStyle: AppTypography.headline.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.darkTextPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.inversePrimary,
          foregroundColor: AppColors.onPrimaryFixed,
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          textStyle: AppTypography.headline.copyWith(
            color: AppColors.onPrimaryFixed,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.inversePrimary,
          side: const BorderSide(color: AppColors.darkDivider),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          textStyle:
              AppTypography.headline.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.inversePrimary,
          textStyle:
              AppTypography.subheadline.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.darkDivider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.darkDivider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide:
              const BorderSide(color: AppColors.inversePrimary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle:
            AppTypography.body.copyWith(color: AppColors.darkTextSecondary),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: const BorderSide(color: AppColors.darkDivider, width: 1),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedColor: AppColors.inversePrimary,
        labelStyle: AppTypography.subheadline
            .copyWith(color: AppColors.darkTextSecondary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        side: const BorderSide(color: AppColors.darkDivider),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface.withValues(alpha: 0.9),
        elevation: 0,
        selectedItemColor: AppColors.inversePrimary,
        unselectedItemColor: AppColors.darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkDivider,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surface,
        contentTextStyle:
            AppTypography.body.copyWith(color: AppColors.onSurface),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        titleTextStyle: AppTypography.headline.copyWith(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.inversePrimary,
        foregroundColor: AppColors.onPrimaryFixed,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.inversePrimary,
        unselectedLabelColor: AppColors.darkTextSecondary,
        indicatorColor: AppColors.inversePrimary,
        labelStyle: AppTypography.subheadline.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTypography.subheadline,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.inversePrimary;
          }
          return AppColors.darkDivider;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.inversePrimary;
          }
          return AppColors.darkTextSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.inversePrimary.withValues(alpha: 0.5);
          }
          return AppColors.darkDivider;
        }),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.inversePrimary;
          }
          return AppColors.darkTextSecondary;
        }),
      ),
      listTileTheme: ListTileThemeData(
        tileColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        titleTextStyle: AppTypography.body.copyWith(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        subtitleTextStyle: AppTypography.subheadline.copyWith(
          color: AppColors.darkTextSecondary,
        ),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(
          AppColors.darkDivider.withValues(alpha: 0.8),
        ),
        radius: const Radius.circular(AppRadius.full),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: AppTypography.caption.copyWith(
          color: AppColors.darkTextPrimary,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        textStyle: AppTypography.body.copyWith(
          color: AppColors.darkTextPrimary,
        ),
      ),
    );
  }
}
