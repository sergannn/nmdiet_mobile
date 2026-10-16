import 'package:flutter/material.dart';
import 'brand_config.dart';
export 'brand_config.dart';

ThemeData appTheme() => ThemeData(
  useMaterial3: true,
  fontFamily: Brand.fontFamily,
  colorScheme: const ColorScheme.light(
    primary: AppColors.navy,
    onPrimary: AppColors.white,
    secondary: AppColors.softBlue,
    onSecondary: AppColors.white,
    surface: AppColors.white,
    onSurface: AppColors.ink,
    error: AppColors.error,
    onError: AppColors.white,
    outline: AppColors.line,
  ),
  scaffoldBackgroundColor: AppColors.white,
  textTheme: const TextTheme(
    headlineLarge: Brand.heroTitle,
    headlineMedium: Brand.title,
    titleLarge: Brand.sectionTitle,
    titleMedium: Brand.cardTitle,
    bodyLarge: Brand.bodyInk,
    bodyMedium: Brand.body,
    bodySmall: Brand.small,
    labelLarge: Brand.button,
  ).apply(fontFamily: Brand.fontFamily),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.white,
    foregroundColor: AppColors.ink,
    surfaceTintColor: AppColors.transparent,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: Brand.cardTitle,
  ),
  dividerTheme: const DividerThemeData(color: AppColors.line, thickness: 1),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size(48, Brand.controlHeight),
      padding: const EdgeInsets.symmetric(horizontal: 27),
      textStyle: Brand.button,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Brand.controlRadius),
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(48, Brand.controlHeight),
      textStyle: Brand.button,
      foregroundColor: AppColors.ink,
      side: const BorderSide(color: AppColors.line),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Brand.controlRadius),
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      textStyle: Brand.small,
      foregroundColor: AppColors.ink,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.white,
    labelStyle: Brand.small,
    hintStyle: Brand.small,
    contentPadding: const EdgeInsets.all(14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(Brand.fieldRadius),
      borderSide: const BorderSide(color: AppColors.line),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(Brand.fieldRadius),
      borderSide: const BorderSide(color: AppColors.line),
    ),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: AppColors.white,
    selectedColor: AppColors.ink,
    labelStyle: Brand.small.copyWith(color: AppColors.ink),
    side: const BorderSide(color: AppColors.line),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Brand.fieldRadius),
    ),
  ),
  navigationBarTheme: NavigationBarThemeData(
    height: 64,
    backgroundColor: AppColors.white,
    indicatorColor: AppColors.mist,
    surfaceTintColor: AppColors.transparent,
    iconTheme: WidgetStateProperty.all(
      const IconThemeData(color: AppColors.ink, size: 24),
    ),
    labelTextStyle: WidgetStateProperty.all(
      Brand.caption.copyWith(color: AppColors.ink),
    ),
  ),
);
