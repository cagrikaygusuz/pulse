import 'package:flutter/material.dart';

/// Pulse app color palette based on brand guidelines
class AppColors {
  AppColors._();

  // Primary Accent - Focus/Energy (Turuncu/Kırmızı)
  static const Color primaryAccent = Color(0xFFED6B06);
  
  // Secondary Accent - Long Break/Intensity (Bordo/Koyu Pempe)
  static const Color secondaryAccent = Color(0xFF9D1348);
  
  // Success - Completion/Achievement (Koyu Yeşil/Zümrüt)
  static const Color success = Color(0xFF008B5D);
  
  // Primary Background - Discipline/Trust (Koyu Mavi/Çivit)
  static const Color primaryBackground = Color(0xFF364395);

  // Additional colors for UI components
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color darkGrey = Color(0xFF424242);
  
  // Status colors
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  
  // Timer specific colors
  static const Color timerBackground = Color(0xFFF8F9FA);
  static const Color timerBorder = Color(0xFFE0E0E0);
  static const Color breakBackground = Color(0xFFE8F5E8);
  static const Color workBackground = Color(0xFFFFF3E0);
  
  // Gradient colors for visual countdown
  static const List<Color> timerGradient = [
    primaryAccent,
    secondaryAccent,
  ];
  
  static const List<Color> breakGradient = [
    success,
    Color(0xFF4CAF50),
  ];
  
  // Heatmap intensity colors
  static const List<Color> heatmapIntensity = [
    Color(0xFFF5F5F5), // No sessions
    Color(0xFFE3F2FD), // 1-2 sessions
    Color(0xFFBBDEFB), // 3-5 sessions
    Color(0xFF90CAF9), // 6-8 sessions
    primaryAccent,     // 9+ sessions
  ];
  
  // Achievement category colors
  static const Color consistencyColor = Color(0xFF4CAF50);
  static const Color volumeColor = Color(0xFF2196F3);
  static const Color disciplineColor = Color(0xFF9C27B0);
  
  // Dark theme colors
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkCard = Color(0xFF1E1E1E);
  static const Color darkDivider = Color(0xFF333333);
  
  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textOnPrimary = white;
  static const Color textOnDark = Color(0xFFE0E0E0);
  
  // Shadow colors
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);
  static const Color shadowDark = Color(0x4D000000);
}
