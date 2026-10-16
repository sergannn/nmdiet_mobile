import 'package:flutter/material.dart';

/// Shared visual tokens. Content and product data live outside the theme.
abstract final class Brand {
  static const fontFamily = 'TildaSans';
  static const pageWidth = 760.0;
  static const gutter = 18.0;
  static const sectionGap = 64.0;
  static const headerHeight = 82.0;
  static const headerGutter = 20.0;
  static const logoWidth = 120.0;
  static const logoHeight = 48.0;
  static const trustHeight = 68.0;
  static const trustGap = 3.0;
  static const heroPhotoHeight = 245.0;
  static const productPhotoHeight = 388.0;
  static const controlHeight = 54.0;
  static const controlRadius = 28.0;
  static const panelRadius = 24.0;
  static const tileRadius = 8.0;
  static const fieldRadius = 6.0;
  static const tileHeight = 470.0;
  static const logo = 'assets/brand/site/logo.webp';
  static const bag = 'assets/brand/site/bag.png';
  static const heroPhoto = 'assets/brand/site/products.webp';
  static const heroSurface = 'assets/brand/site/hero-surface.png';
  static const founderPhoto = 'assets/brand/site/founder.webp';
  static const heroTitle = TextStyle(
    fontSize: 42,
    height: 1.02,
    fontWeight: FontWeight.w400,
    color: AppColors.navy,
    letterSpacing: 0,
  );
  static const heroSubtitle = TextStyle(
    fontSize: 26,
    height: 1.12,
    fontWeight: FontWeight.w300,
    color: AppColors.softBlue,
    letterSpacing: 0,
  );
  static const title = TextStyle(
    fontSize: 32,
    height: 1.12,
    fontWeight: FontWeight.w400,
    color: AppColors.ink,
    letterSpacing: 0,
  );
  static const productTitle = TextStyle(
    fontSize: 38,
    height: 1.12,
    fontWeight: FontWeight.w400,
    color: AppColors.ink,
    letterSpacing: 0,
  );
  static const sectionTitle = TextStyle(
    fontSize: 30,
    height: 1.16,
    fontWeight: FontWeight.w400,
    color: AppColors.navy,
    letterSpacing: 0,
  );
  static const cardTitle = TextStyle(
    fontSize: 23,
    height: 1.2,
    fontWeight: FontWeight.w400,
    color: AppColors.navy,
    letterSpacing: 0,
  );
  static const body = TextStyle(
    fontSize: 17,
    height: 1.55,
    fontWeight: FontWeight.w400,
    color: AppColors.muted,
    letterSpacing: 0,
  );
  static const bodyInk = TextStyle(
    fontSize: 17,
    height: 1.55,
    color: AppColors.ink,
    letterSpacing: 0,
  );
  static const small = TextStyle(
    fontSize: 14,
    height: 1.5,
    color: AppColors.muted,
    letterSpacing: 0,
  );
  static const caption = TextStyle(
    fontSize: 12,
    height: 1.5,
    color: AppColors.muted,
    letterSpacing: 0,
  );
  static const eyebrow = TextStyle(
    fontSize: 13,
    height: 1.3,
    fontWeight: FontWeight.w500,
    color: AppColors.navy,
    letterSpacing: 0,
  );
  static const trustTitle = TextStyle(
    fontSize: 15,
    height: 1.35,
    fontWeight: FontWeight.w500,
    color: AppColors.headerText,
    letterSpacing: 0,
  );
  static const trustProof = TextStyle(
    fontSize: 14,
    height: 1.35,
    fontWeight: FontWeight.w400,
    color: AppColors.headerText,
    letterSpacing: 0,
  );
  static const trustStrong = TextStyle(fontWeight: FontWeight.w600);
  static const headerMenu = TextStyle(
    fontSize: 15,
    height: 1,
    fontWeight: FontWeight.w500,
    color: AppColors.ink,
    letterSpacing: 0,
  );
  static const productEyebrow = TextStyle(
    fontSize: 10,
    height: 1.3,
    color: AppColors.softBlue,
    letterSpacing: 0,
  );
  static const button = TextStyle(
    fontSize: 17,
    height: 1,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );
  static const price = TextStyle(
    fontSize: 30,
    height: 1.2,
    fontWeight: FontWeight.w500,
    color: AppColors.ink,
    letterSpacing: 0,
  );
  static const compactPrice = TextStyle(
    fontSize: 23,
    height: 1.2,
    fontWeight: FontWeight.w500,
    color: AppColors.ink,
    letterSpacing: 0,
  );
}

abstract final class AppColors {
  static const headerText = Color(0xFF155483);
  static const ink = Color(0xFF194C80);
  static const navy = Color(0xFF0A2F67);
  static const blue = Color(0xFF2182C5);
  static const softBlue = Color(0xFF3A6C92);
  static const mist = Color(0xFFF1F8FC);
  static const catalog = Color(0xFFEDF6FC);
  static const panel = Color(0xFFF5F8FB);
  static const lavender = Color(0xFFEEECF7);
  static const muted = Color(0xFF626B74);
  static const line = Color(0xFFCCE0EF);
  static const accent = Color(0xFF7DBDDE);
  static const green = Color(0xFF388275);
  static const rating = Color(0xFFAE7620);
  static const white = Color(0xFFFFFFFF);
  static const transparent = Color(0x00000000);
  static const error = Color(0xFF9B3326);
  static const errorSurface = Color(0xFFFCEEEA);
  static const footer = Color(0xFFF6F9FB);
}
