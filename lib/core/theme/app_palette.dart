import 'package:flutter/material.dart';

/// Couleurs de base d'un thème (fond, surfaces, bordures, textes).
class AppPalette {
  const AppPalette({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.surfaceHigh,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
  });

  final Brightness brightness;
  final Color background;
  final Color surface;
  final Color surfaceHigh;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;

  static const dark = AppPalette(
    brightness: Brightness.dark,
    background: Color(0xFF0F1117),
    surface: Color(0xFF171A23),
    surfaceHigh: Color(0xFF1F2330),
    border: Color(0xFF2A2F3E),
    textPrimary: Color(0xFFE6E8F0),
    textSecondary: Color(0xFF9AA1B5),
  );

  static const light = AppPalette(
    brightness: Brightness.light,
    background: Color(0xFFF6F7FB),
    surface: Color(0xFFFFFFFF),
    surfaceHigh: Color(0xFFF0F2F8),
    border: Color(0xFFE3E6EF),
    textPrimary: Color(0xFF1B1F2A),
    textSecondary: Color(0xFF5B6275),
  );
}

/// Couleurs à signification, identiques dans les deux thèmes.
class AppColors {
  static const primary = Color(0xFF6366F1);
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);
  static const info = Color(0xFF38BDF8);
}

/// Espacements (multiples de 4).
class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

/// Rayons d'arrondi.
class AppRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
}