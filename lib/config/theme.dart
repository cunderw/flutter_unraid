import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_unraid/config/spacing.dart';

class AppColors {
  AppColors._();

  static const unraidOrange = Color(0xFFFF8C2F);

  // Status colors (theme-independent)
  static const running = Color(0xFF4CAF50);
  static const stopped = Color(0xFFF44336);
  static const warning = Color(0xFFFFC107);
  static const paused = Color(0xFF2196F3);
  static const offline = Color(0xFF757575);

  static Color forContainerState(String state) {
    return switch (state.toUpperCase()) {
      'RUNNING' => running,
      'PAUSED' => paused,
      'EXITED' => stopped,
      _ => offline,
    };
  }

  static Color forVmState(String state) {
    return switch (state.toUpperCase()) {
      'RUNNING' => running,
      'PAUSED' => paused,
      'SHUTOFF' || 'SHUTDOWN' => stopped,
      'CRASHED' => stopped,
      'IDLE' => warning,
      _ => offline,
    };
  }

  static Color forArrayState(String state) {
    return switch (state.toUpperCase()) {
      'STARTED' => running,
      'STOPPED' => stopped,
      _ => warning,
    };
  }

  static Color forDiskStatus(String? status) {
    return switch (status?.toUpperCase()) {
      'DISK_OK' => running,
      'DISK_NP' || 'DISK_NP_MISSING' || 'DISK_NP_DSBL' => offline,
      'DISK_INVALID' || 'DISK_WRONG' || 'DISK_DSBL' => stopped,
      _ => offline,
    };
  }
}

// ── Dark Theme ────────────────────────────────────────────────────────────────

final ThemeData unraidDarkTheme = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.unraidOrange,
    secondary: AppColors.unraidOrange,
    surface: Color(0xFF2A2C2E),
    surfaceContainerHigh: Color(0xFF333537),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Color(0xFFE0E0E0),
    onSurfaceVariant: Color(0xFF9E9E9E),
    outline: Color(0xFF404244),
    error: AppColors.stopped,
  ),
  scaffoldBackgroundColor: const Color(0xFF1B1D1F),
  cardTheme: const CardThemeData(
    color: Color(0xFF333537),
    elevation: 1,
    margin: EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.xs,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      side: BorderSide(color: Color(0xFF404244), width: 0.5),
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1B1D1F),
    foregroundColor: Color(0xFFE0E0E0),
    elevation: 0,
    scrolledUnderElevation: 2,
    shadowColor: Colors.black,
    centerTitle: false,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF2A2C2E),
    selectedItemColor: AppColors.unraidOrange,
    unselectedItemColor: Color(0xFF9E9E9E),
    type: BottomNavigationBarType.fixed,
  ),
  navigationBarTheme: NavigationBarThemeData(
    indicatorShape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF2A2C2E),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF404244)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF404244)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.unraidOrange, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.stopped),
    ),
    labelStyle: const TextStyle(color: Color(0xFF9E9E9E)),
    hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.mdl,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.unraidOrange,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.mdl,
      ),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.unraidOrange,
      side: const BorderSide(color: AppColors.unraidOrange),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.mdl,
      ),
    ),
  ),
  iconButtonTheme: IconButtonThemeData(
    style: IconButton.styleFrom(foregroundColor: const Color(0xFF9E9E9E)),
  ),
  dividerTheme: const DividerThemeData(
    color: Color(0xFF404244),
    thickness: 0.5,
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: const Color(0xFF333537),
    contentTextStyle: const TextStyle(color: Color(0xFFE0E0E0)),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    behavior: SnackBarBehavior.floating,
  ),
  textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
);

// ── Light Theme ───────────────────────────────────────────────────────────────

final ThemeData unraidLightTheme = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,
  colorScheme: const ColorScheme.light(
    primary: AppColors.unraidOrange,
    secondary: AppColors.unraidOrange,
    surface: Color(0xFFF5F5F5),
    surfaceContainerHigh: Colors.white,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Color(0xFF1B1D1F),
    onSurfaceVariant: Color(0xFF616161),
    outline: Color(0xFFE0E0E0),
    error: AppColors.stopped,
  ),
  scaffoldBackgroundColor: const Color(0xFFFAFAFA),
  cardTheme: const CardThemeData(
    color: Colors.white,
    elevation: 1,
    margin: EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.xs,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      side: BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFFAFAFA),
    foregroundColor: Color(0xFF1B1D1F),
    elevation: 0,
    scrolledUnderElevation: 2,
    shadowColor: Colors.black12,
    centerTitle: false,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: AppColors.unraidOrange,
    unselectedItemColor: Color(0xFF616161),
    type: BottomNavigationBarType.fixed,
  ),
  navigationBarTheme: NavigationBarThemeData(
    indicatorShape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.unraidOrange, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.stopped),
    ),
    labelStyle: const TextStyle(color: Color(0xFF616161)),
    hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.mdl,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.unraidOrange,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.mdl,
      ),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.unraidOrange,
      side: const BorderSide(color: AppColors.unraidOrange),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.mdl,
      ),
    ),
  ),
  iconButtonTheme: IconButtonThemeData(
    style: IconButton.styleFrom(foregroundColor: const Color(0xFF616161)),
  ),
  dividerTheme: const DividerThemeData(
    color: Color(0xFFE0E0E0),
    thickness: 0.5,
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: Colors.white,
    contentTextStyle: const TextStyle(color: Color(0xFF1B1D1F)),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    behavior: SnackBarBehavior.floating,
  ),
  textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
);
