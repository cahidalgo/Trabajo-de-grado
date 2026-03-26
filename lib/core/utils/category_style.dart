import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class CategoryStyle {
  final Color background;
  final Color accent;
  final IconData icon;

  const CategoryStyle({
    required this.background,
    required this.accent,
    required this.icon,
  });
}

class AppCategoryStyles {
  static CategoryStyle resolve(String? rawCategory) {
    final category = (rawCategory ?? '').toLowerCase().trim();

    if (category.contains('venta')) {
      return const CategoryStyle(
        background: Color(0xFFE3F2FD),
        accent: Color(0xFF1565C0),
        icon: Icons.storefront_outlined,
      );
    }
    if (category.contains('gastron')) {
      return const CategoryStyle(
        background: Color(0xFFFFF3E0),
        accent: Color(0xFFE65100),
        icon: Icons.restaurant_outlined,
      );
    }
    if (category.contains('log')) {
      return const CategoryStyle(
        background: Color(0xFFE8F5E9),
        accent: Color(0xFF2E7D32),
        icon: Icons.local_shipping_outlined,
      );
    }
    if (category.contains('servicio')) {
      return const CategoryStyle(
        background: Color(0xFFF3E5F5),
        accent: Color(0xFF6A1B9A),
        icon: Icons.support_agent_outlined,
      );
    }
    if (category.contains('digital')) {
      return const CategoryStyle(
        background: Color(0xFFE0F7FA),
        accent: Color(0xFF00695C),
        icon: Icons.computer_outlined,
      );
    }
    if (category.contains('empr')) {
      return const CategoryStyle(
        background: Color(0xFFFFF9C4),
        accent: Color(0xFFF57F17),
        icon: Icons.lightbulb_outlined,
      );
    }
    if (category.contains('habil')) {
      return const CategoryStyle(
        background: Color(0xFFFCE4EC),
        accent: Color(0xFFC62828),
        icon: Icons.people_outline,
      );
    }
    if (category.contains('constru')) {
      return const CategoryStyle(
        background: Color(0xFFFBE9E7),
        accent: Color(0xFFBF360C),
        icon: Icons.construction_outlined,
      );
    }

    return const CategoryStyle(
      background: AppColors.primaryLight,
      accent: AppColors.primary,
      icon: Icons.work_outline,
    );
  }
}
