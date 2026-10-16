import 'package:flutter/material.dart';

abstract final class AppColors {
  static const ink = Color(0xFF123C65);
  static const blue = Color(0xFF1763A5);
  static const mist = Color(0xFFEDF5FA);
  static const muted = Color(0xFF687F91);
  static const line = Color(0xFFDCE7EE);
  static const green = Color(0xFF388275);
}

ThemeData appTheme() => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.blue,
    brightness: Brightness.light,
    primary: AppColors.ink,
    secondary: AppColors.green,
    surface: Colors.white,
  ),
  scaffoldBackgroundColor: Colors.white,
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 32,
      height: 1.15,
      fontWeight: FontWeight.w600,
      color: AppColors.ink,
    ),
    headlineMedium: TextStyle(
      fontSize: 26,
      height: 1.2,
      fontWeight: FontWeight.w500,
      color: AppColors.ink,
    ),
    titleLarge: TextStyle(
      fontSize: 21,
      fontWeight: FontWeight.w600,
      color: AppColors.ink,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.ink,
    ),
    bodyLarge: TextStyle(fontSize: 16, height: 1.6, color: AppColors.ink),
    bodyMedium: TextStyle(fontSize: 14, height: 1.5, color: AppColors.muted),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: AppColors.ink,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    centerTitle: false,
  ),
  dividerTheme: const DividerThemeData(color: AppColors.line, thickness: 1),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size(48, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(48, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFF7FAFC),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.line),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.line),
    ),
  ),
  navigationBarTheme: const NavigationBarThemeData(
    backgroundColor: Colors.white,
    indicatorColor: AppColors.mist,
    surfaceTintColor: Colors.transparent,
  ),
);
