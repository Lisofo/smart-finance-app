import 'package:flutter/material.dart';

/// Visual identity per expense category — icons + accent colors for charts and cards.
abstract final class CategoryStyles {
  static IconData iconFor(String? category) {
    switch (category?.toLowerCase()) {
      case 'food':
        return Icons.restaurant_rounded;
      case 'transport':
        return Icons.directions_car_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'bills':
        return Icons.receipt_long_rounded;
      case 'entertainment':
        return Icons.movie_rounded;
      case 'health':
        return Icons.favorite_rounded;
      case 'other':
        return Icons.category_rounded;
      default:
        return Icons.layers_rounded;
    }
  }

  /// Saturated accent for charts and category chips.
  static Color colorFor(String? category) {
    switch (category?.toLowerCase()) {
      case 'food':
        return const Color(0xFFF97316);
      case 'transport':
        return const Color(0xFF6366F1);
      case 'shopping':
        return const Color(0xFFEC4899);
      case 'bills':
        return const Color(0xFF14B8A6);
      case 'entertainment':
        return const Color(0xFFA855F7);
      case 'health':
        return const Color(0xFFEF4444);
      case 'other':
        return const Color(0xFF64748B);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  /// Softer background tint for list tiles / icons.
  static Color surfaceTintFor(String? category) {
    return colorFor(category).withValues(alpha: 0.14);
  }
}
