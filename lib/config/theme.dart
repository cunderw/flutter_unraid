import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_unraid/config/spacing.dart';

class AppColors {
  AppColors._();

  static const background = Color(0xFF1B1D1F);
  static const surface = Color(0xFF2A2C2E);
  static const card = Color(0xFF333537);
  static const divider = Color(0xFF404244);
  static const unraidOrange = Color(0xFFFF8C2F);
  static const textPrimary = Color(0xFFE0E0E0);
  static const textSecondary = Color(0xFF9E9E9E);

  // Status colors
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

final ThemeData unraidDarkTheme = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.unraidOrange,
    secondary: AppColors.unraidOrange,
    surface: AppColors.surface,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: AppColors.textPrimary,
    error: AppColors.stopped,
  ),
  scaffoldBackgroundColor: AppColors.background,
  cardTheme: const CardThemeData(
    color: AppColors.card,
    elevation: 1,
    margin: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.background,
    foregroundColor: AppColors.textPrimary,
    elevation: 0,
    centerTitle: false,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.surface,
    selectedItemColor: AppColors.unraidOrange,
    unselectedItemColor: AppColors.textSecondary,
    type: BottomNavigationBarType.fixed,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.divider),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.divider),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.unraidOrange, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.stopped),
    ),
    labelStyle: const TextStyle(color: AppColors.textSecondary),
    hintStyle: const TextStyle(color: AppColors.textSecondary),
    contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.mdl),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.unraidOrange,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.mdl),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.unraidOrange,
      side: const BorderSide(color: AppColors.unraidOrange),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.mdl),
    ),
  ),
  iconButtonTheme: IconButtonThemeData(
    style: IconButton.styleFrom(foregroundColor: AppColors.textSecondary),
  ),
  dividerTheme: const DividerThemeData(
    color: AppColors.divider,
    thickness: 0.5,
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: AppColors.card,
    contentTextStyle: const TextStyle(color: AppColors.textPrimary),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    behavior: SnackBarBehavior.floating,
  ),
  textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
);
