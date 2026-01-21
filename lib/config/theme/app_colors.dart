import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryTeal = Color(0xFF2C5F7C);
  static const Color lightTeal = Color(0xFF4A90A4);
  static const Color accentGreen = Color(0xFF5FB573);
  static const Color accentYellow = Color(0xFFF4B942);

  static const Color darkGray = Color(0xFF1F2937);
  static const Color mediumGray = Color(0xFF6B7280);
  static const Color lightGray = Color(0xFF9CA3AF);
  static const Color backgroundGray = Color(0xFFF9FAFB);
  static const Color white = Color(0xFFFFFFFF);

  static const Color success = accentGreen;
  static const Color warning = accentYellow;
  static const Color error = Color(0xFFEF4444);
  static const Color info = lightTeal;

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryTeal, lightTeal],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentGreen, accentYellow],
  );
}