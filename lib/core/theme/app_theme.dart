import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFF0F0F0F);
  static const surface = Color(0xFF161A23);
  static const surfaceBorder = Color(0xFF2A2F3A);
  static const green = Color(0xFF34D367);
  static const white = Colors.white;
  static const whiteMuted = Color(0xFFB0B0B0);
  static const whiteDim = Color(0xFF606060);
}

final appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.background,
  colorScheme: const ColorScheme.dark(
    surface: AppColors.surface,
    primary: AppColors.green,
    onSurface: AppColors.white,
  ),
  dialogTheme: const DialogThemeData(
    backgroundColor: AppColors.surface,
    titleTextStyle: TextStyle(
      color: AppColors.white,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
    contentTextStyle: TextStyle(color: AppColors.whiteMuted, fontSize: 14),
  ),
);
