import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF1A73E8);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color secondary = Color(0xFF34A853);
  static const Color secondaryDark = Color(0xFF0D8F3D);

  // Status Colors
  static const Color success = Color(0xFF00C853);
  static const Color warning = Color(0xFFFFB300);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF2196F3);

  // Text Colors
  static const Color textPrimary = Color(0xFF202124);
  static const Color textSecondary = Color(0xFF5F6368);
  static const Color textHint = Color(0xFF9AA0A6);
  static const Color textLight = Color(0xFFFFFFFF);

  // Background Colors
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Border Colors
  static const Color border = Color(0xFFDADCE0);
  static const Color borderDark = Color(0xFF3D3D3D);
  static const Color divider = Color(0xFFE8EAED);

  // Chart Colors
  static const Color chartBlue = Color(0xFF4285F4);
  static const Color chartGreen = Color(0xFF34A853);
  static const Color chartRed = Color(0xFFEA4335);
  static const Color chartYellow = Color(0xFFFBBC05);
  static const Color chartPurple = Color(0xFF9C27B0);
  static const Color chartOrange = Color(0xFFFF6D00);

  // Card Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00C853), Color(0xFF0D8F3D)],
  );

  static const LinearGradient warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFB300), Color(0xFFF57C00)],
  );

  static const LinearGradient dangerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEA4335), Color(0xFFC5221F)],
  );
}