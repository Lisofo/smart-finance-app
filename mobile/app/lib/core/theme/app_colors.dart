import 'package:flutter/material.dart';

/// Design tokens — use [ThemeData.colorScheme] in widgets; use these for
/// marketing alignment and chart/category accents.
abstract final class AppColors {
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1E3A8A);
  static const Color primaryLight = Color(0xFFDBEAFE);

  /// Secondary accent (charts, highlights) — teal.
  static const Color secondary = Color(0xFF0D9488);
  static const Color secondaryLight = Color(0xFFCCFBF1);

  static const Color background = Color(0xFFF1F5F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFE2E8F0);

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);

  static const Color success = Color(0xFF22C55E);
  static const Color danger = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  /// Subtle shadow for elevated surfaces (ARGB).
  static const Color shadow = Color(0x140F172A);
}
