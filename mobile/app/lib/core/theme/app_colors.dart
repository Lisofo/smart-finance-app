import 'package:flutter/material.dart';

/// Fintech palette — use via [ThemeData.colorScheme] in UI; reference here for
/// one-off cases that must match marketing / illustrations.
abstract final class AppColors {
  static const Color primary = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1E3A8A);
  static const Color primaryLight = Color(0xFFDBEAFE);

  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);

  static const Color success = Color(0xFF22C55E);
  static const Color danger = Color(0xFFEF4444);
}
