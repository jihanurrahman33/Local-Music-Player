import 'package:flutter/material.dart';

/// YouTube Music inspired dark color tokens.
/// Values are approximations based on public references; refine against real screenshots.
class AppColors {
  AppColors._();

  // Backgrounds
  static const Color background = Color(0xFF030303);
  static const Color surface = Color(0xFF121212);
  static const Color surfaceElevated = Color(0xFF1A1A1A);
  static const Color surfaceCard = Color(0xFF181818);
  static const Color surfaceHighlight = Color(0xFF222222);

  // Brand / accent
  static const Color primary = Color(0xFFFF0000);
  static const Color primarySoft = Color(0xFFCC0000);
  static const Color onPrimary = Colors.white;

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textTertiary = Color(0xFF808080);
  static const Color textDisabled = Color(0xFF555555);

  // Borders / dividers
  static const Color divider = Color(0xFF2A2A2A);
  static const Color outline = Color(0xFF333333);

  // Semantic
  static const Color error = Color(0xFFCF6679);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFB74D);

  // Player specific
  static const Color miniPlayerBg = Color(0xFF1C1C1C);
  static const Color progressInactive = Color(0xFF404040);
  static const Color progressActive = Color(0xFFFFFFFF);
}
