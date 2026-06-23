import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFF4A654E);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF8BA88E);
  static const onPrimaryContainer = Color(0xFF233D29);
  static const primaryFixed = Color(0xFFCCEACE);
  static const primaryFixedDim = Color(0xFFB0CEB2);

  static const secondary = Color(0xFF605E58);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFE6E2D9);
  static const onSecondaryContainer = Color(0xFF66645E);

  static const tertiary = Color(0xFF8D4C3F);
  static const onTertiary = Color(0xFFFFFFFF);
  static const tertiaryContainer = Color(0xFFDB8D7D);
  static const onTertiaryContainer = Color(0xFF5E271C);

  static const surface = Color(0xFFFBF9F8);
  static const surfaceDim = Color(0xFFDBDAD9);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF5F3F3);
  static const surfaceContainer = Color(0xFFEFEDED);
  static const surfaceContainerHigh = Color(0xFFE9E8E7);
  static const surfaceContainerHighest = Color(0xFFE4E2E2);
  static const onSurface = Color(0xFF1B1C1C);
  static const onSurfaceVariant = Color(0xFF424842);

  static const outline = Color(0xFF737972);
  static const outlineVariant = Color(0xFFC2C8C0);

  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);

  static const background = Color(0xFFFBF9F8);
  static const onBackground = Color(0xFF1B1C1C);

  static const cardBorder = Color(0xFFF2EBDC);
  static const cardShadow = Color(0xFF4A654E);
}

class AppSpacing {
  static const double base = 8;
  static const double containerPadding = 20;
  static const double gutter = 16;
  static const double stackSm = 4;
  static const double stackMd = 12;
  static const double stackLg = 24;
}

class AppRadius {
  static const double sm = 4;
  static const double md = 8;
  static const double lg = 16;
  static const double xl = 24;
  static const double full = 9999;
}

class AppTheme {
  static BoxShadow get cardShadow => BoxShadow(
        color: AppColors.cardShadow.withValues(alpha: 0.08),
        blurRadius: 12,
        offset: const Offset(0, 4),
      );

  static BoxShadow get navShadow => BoxShadow(
        color: AppColors.cardShadow.withValues(alpha: 0.10),
        blurRadius: 12,
        offset: const Offset(0, -4),
      );

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
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
          error: Color(0xFFBA1A1A),
          onError: Color(0xFFFFFFFF),
          surface: AppColors.surface,
          onSurface: AppColors.onSurface,
          onSurfaceVariant: AppColors.onSurfaceVariant,
          outline: AppColors.outline,
          outlineVariant: AppColors.outlineVariant,
          surfaceContainerHighest: AppColors.surfaceContainerHighest,
        ),
        scaffoldBackgroundColor: AppColors.background,
        textTheme: TextTheme(
          headlineLarge: GoogleFonts.plusJakartaSans(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            height: 32 / 26,
            color: AppColors.onSurface,
          ),
          headlineMedium: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            height: 32 / 24,
            color: AppColors.onSurface,
          ),
          bodyLarge: GoogleFonts.beVietnamPro(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            height: 28 / 18,
            color: AppColors.onSurface,
          ),
          bodyMedium: GoogleFonts.beVietnamPro(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 24 / 16,
            color: AppColors.onSurface,
          ),
          labelLarge: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 20 / 14,
            letterSpacing: 0.01 * 14,
            color: AppColors.onSurface,
          ),
          labelSmall: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 16 / 12,
            color: AppColors.onSurface,
          ),
        ),
      );
}
