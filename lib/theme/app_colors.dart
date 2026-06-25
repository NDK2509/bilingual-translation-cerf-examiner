import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color secondary = Color(0xFFEC4899); // Pink/Rose
  static const Color accent = Color(0xFF8B5CF6); // Violet

  // Theme Colors (Sleek Dark Mode First)
  static const Color background = Color(0xFF0B0F19); // Rich Deep Blue-Grey
  static const Color surface = Color(0xFF171E2E); // Deep Card Slate
  static const Color surfaceElevated = Color(0xFF232D42); // Elevated Slate
  
  // Status Colors
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Crimson Rose
  static const Color info = Color(0xFF3B82F6); // Royal Blue

  // Text Colors
  static const Color textPrimary = Color(0xFFF9FAFB);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);

  // Borders & Accents
  static const Color border = Color(0xFF2D3748);
  static const Color borderLight = Color(0xFF3E4E68);

  // Background Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Premium Glassmorphism Decoration
  static BoxDecoration glassCardDecoration({
    Color color = surface,
    double radius = 16.0,
    double borderWidth = 1.0,
  }) {
    return BoxDecoration(
      color: color.withOpacity(0.85),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderLight.withOpacity(0.4),
        width: borderWidth,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
