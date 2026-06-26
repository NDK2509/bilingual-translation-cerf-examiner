import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF00D1FF); // Glowing Cyan
  static const Color primaryDark = Color(0xFF0052FF); // Deep Royal Blue
  static const Color secondary = Color(0xFF0075FF); // Vibrant Blue
  static const Color accent = Color(0xFF00A3FF); // Medium Neon Blue

  // Theme Colors (Sleek Dark Mode First)
  static const Color background = Color(0xFF040711); // Rich Black-Navy
  static const Color surface = Color(0xFF0D1324); // Dark Translucent Slate
  static const Color surfaceElevated = Color(0xFF141D35); // Elevated Slate
  
  // Status Colors
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Crimson Rose
  static const Color info = Color(0xFF3B82F6); // Royal Blue

  // Text Colors
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF475569);

  // Borders & Accents
  static const Color border = Color(0xFF1C2C54);
  static const Color borderLight = Color(0xFF283D70);

  // Background Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glow Background Decoration
  static const RadialGradient bgGlow = RadialGradient(
    colors: [Color(0x330052FF), Colors.transparent],
    center: Alignment.bottomCenter,
    radius: 1.6,
  );

  // Premium Glassmorphism Decoration
  static BoxDecoration glassCardDecoration({
    Color color = surface,
    double radius = 16.0,
    double borderWidth = 1.0,
  }) {
    return BoxDecoration(
      color: color.withOpacity(0.65),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderLight.withOpacity(0.25),
        width: borderWidth,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  // Premium Standout Card Decoration
  static BoxDecoration premiumCardDecoration({
    double radius = 16.0,
    double borderWidth = 1.0,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          surfaceElevated.withOpacity(0.80),
          surface.withOpacity(0.85),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderLight.withOpacity(0.35),
        width: borderWidth,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.35),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}
