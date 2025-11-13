import 'package:flutter/material.dart';

class AppTheme {
  // Color tokens
  static const Color primary = Color(0xFF1976D2); // Blue
  static const Color secondary = Color(0xFF03DAC6); // Teal
  static const Color neutral = Color(0xFF9E9E9E); // Grey
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color background = Color(0xFFF5F5F5); // Light grey
  static const Color error = Color(0xFFD32F2F); // Red
  static const Color onPrimary = Color(0xFFFFFFFF); // White text on primary
  static const Color onSecondary = Color(0xFF000000); // Black text on secondary
  static const Color onSurface = Color(0xFF000000); // Black text on surface

  // Additional light theme colors
  static const Color primaryContainer = Color(0xFFBBDEFB);
  static const Color onPrimaryContainer = Color(0xFF000000);
  static const Color secondaryContainer = Color(0xFFB2DFDB);
  static const Color onSecondaryContainer = Color(0xFF000000);
  static const Color tertiary = Color(0xFFFFC107);
  static const Color onTertiary = Color(0xFF000000);
  static const Color tertiaryContainer = Color(0xFFFFF8E1);
  static const Color onTertiaryContainer = Color(0xFF000000);
  static const Color errorContainer = Color(0xFFFFCDD2);
  static const Color onErrorContainer = Color(0xFF000000);
  static const Color surfaceVariant = Color(0xFFEEEEEE);
  static const Color onSurfaceVariant = Color(0xFF000000);
  static const Color outline = Color(0xFFBDBDBD);
  static const Color outlineVariant = Color(0xFF8D8D8D);
  static const Color shadow = Color(0xFF000000);
  static const Color scrim = Color(0xFF000000);
  static const Color inverseSurface = Color(0xFF000000);
  static const Color onInverseSurface = Color(0xFFFFFFFF);
  static const Color inversePrimary = Color(0xFF90CAF9);
  static const Color surfaceTint = Color(0xFF1976D2);

  // Dark theme colors
  static const Color darkPrimary = Color(0xFF90CAF9);
  static const Color darkSecondary = Color(0xFF80CBC4);
  static const Color darkNeutral = Color(0xFFBDBDBD);
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkBackground = Color(0xFF1E1E1E);
  static const Color darkError = Color(0xFFEF5350);
  static const Color darkOnPrimary = Color(0xFF000000);
  static const Color darkOnSecondary = Color(0xFF000000);
  static const Color darkOnSurface = Color(0xFFFFFFFF);

  // Additional dark theme colors
  static const Color darkPrimaryContainer = Color(0xFF424242);
  static const Color darkOnPrimaryContainer = Color(0xFFFFFFFF);
  static const Color darkSecondaryContainer = Color(0xFF37474F);
  static const Color darkOnSecondaryContainer = Color(0xFFFFFFFF);
  static const Color darkTertiary = Color(0xFFFFC107);
  static const Color darkOnTertiary = Color(0xFF000000);
  static const Color darkTertiaryContainer = Color(0xFF424242);
  static const Color darkOnTertiaryContainer = Color(0xFFFFFFFF);
  static const Color darkErrorContainer = Color(0xFF5D4037);
  static const Color darkOnErrorContainer = Color(0xFFFFFFFF);
  static const Color darkSurfaceVariant = Color(0xFF424242);
  static const Color darkOnSurfaceVariant = Color(0xFFBDBDBD);
  static const Color darkOutline = Color(0xFF8D8D8D);
  static const Color darkOutlineVariant = Color(0xFF5D5D5D);
  static const Color darkShadow = Color(0xFF000000);
  static const Color darkScrim = Color(0xFF000000);
  static const Color darkInverseSurface = Color(0xFFFFFFFF);
  static const Color darkOnInverseSurface = Color(0xFF000000);
  static const Color darkInversePrimary = Color(0xFF1976D2);
  static const Color darkSurfaceTint = Color(0xFF90CAF9);

  // Typography scale
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.3,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle h4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  // Light theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: onPrimary,
      secondary: secondary,
      onSecondary: onSecondary,
      error: error,
      onError: onPrimary,
      surface: surface,
      onSurface: onSurface,
      background: background,
      onBackground: onSurface,
    ),
    textTheme: const TextTheme(
      displayLarge: h1,
      displayMedium: h2,
      displaySmall: h3,
      headlineLarge: h2,
      headlineMedium: h3,
      headlineSmall: h4,
      titleLarge: h4,
      titleMedium: bodyLarge,
      titleSmall: body,
      bodyLarge: bodyLarge,
      bodyMedium: body,
      bodySmall: bodySmall,
      labelLarge: labelLarge,
      labelMedium: body,
      labelSmall: labelSmall,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: onPrimary,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: const BorderSide(color: primary),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
  );

  // Dark theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: darkPrimary,
      onPrimary: darkOnPrimary,
      secondary: darkSecondary,
      onSecondary: darkOnSecondary,
      error: darkError,
      onError: darkOnPrimary,
      surface: darkSurface,
      onSurface: darkOnSurface,
      background: darkBackground,
      onBackground: darkOnSurface,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: darkOnSurface),
      displayMedium: TextStyle(color: darkOnSurface),
      displaySmall: TextStyle(color: darkOnSurface),
      headlineLarge: TextStyle(color: darkOnSurface),
      headlineMedium: TextStyle(color: darkOnSurface),
      headlineSmall: TextStyle(color: darkOnSurface),
      titleLarge: TextStyle(color: darkOnSurface),
      titleMedium: TextStyle(color: darkOnSurface),
      titleSmall: TextStyle(color: darkOnSurface),
      bodyLarge: TextStyle(color: darkOnSurface),
      bodyMedium: TextStyle(color: darkOnSurface),
      bodySmall: TextStyle(color: darkOnSurface),
      labelLarge: TextStyle(color: darkOnSurface),
      labelMedium: TextStyle(color: darkOnSurface),
      labelSmall: TextStyle(color: darkOnSurface),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkSurface,
      foregroundColor: darkOnSurface,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkPrimary,
        foregroundColor: darkOnPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: darkPrimary,
        side: const BorderSide(color: darkPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
  );
}
