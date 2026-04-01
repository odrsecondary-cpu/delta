import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppColors {
  static const background = Color(0xFF0F0F0F);
  static const surface = Color(0xFF161A23);
  static const surfaceBorder = Color(0xFF2A2F3A);
  static const green = Color(0xFF34D367);
  // History screen accent — brighter green used for section headers and total bar
  static const greenBright = Color(0xFF1AFF8C);
  static const greenBrightMuted = Color(0x331AFF8C); // 20 % opacity
  static const totalBarBg = Color(0xFF0D2A1E);
  static const white = Colors.white;
  static const whiteMuted = Color(0xFFB0B0B0);
  static const whiteDim = Color(0xFF606060);
}

final appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.background,
  textTheme: GoogleFonts.interTextTheme(
    ThemeData.dark().textTheme,
  ),
  colorScheme: const ColorScheme.dark(
    surface: AppColors.surface,
    primary: AppColors.green,
    onSurface: AppColors.white,
  ),
  dialogTheme: const DialogThemeData(
    backgroundColor: AppColors.surface,
    titleTextStyle: TextStyle(
      color: AppColors.white,
      fontSize: 24,
      fontWeight: FontWeight.w600,
    ),
    contentTextStyle: TextStyle(color: AppColors.whiteMuted, fontSize: 20),
  ),
);
