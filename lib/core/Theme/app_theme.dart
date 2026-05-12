import 'package:flutter/material.dart';

class AppTheme {
  // ProjHub Color Scheme - Blue Theme
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color primaryBlueDark = Color(0xFF1976D2);
  static const Color primaryBlueLight = Color(0xFF64B5F6);
  static const Color primaryRed = Color(0xD6FF002A);
  static const Color accentBlue = Color(0xFF42A5F5);
  static const Color lightBlue = Color(0xFFE3F2FD);
  static const Color darkBlue = Color(0xFF1565C0);
  
  // Background colors
  static const Color backgroundLight = Color.fromARGB(255, 222, 233, 247);
  static const Color backgroundDark = Color(0xFF7E9FCA);
  static const Color cardBackground = Colors.white;
  
  // Gradients
  static const LinearGradient homeBackground = LinearGradient(
    colors: [
      Color.fromARGB(255, 222, 233, 247),
      Color(0xFFF4F4F4),
      Color(0xFF7E9FCA),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient aiCardGradient = LinearGradient(
    colors: [
      Color(0xFFE3F2FD),  // أزرق فاتح بدلاً من الأخضر
      Colors.white,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient aiButtonGradient = LinearGradient(
    colors: [
      Color(0xFF2196F3),
      Color(0xFF1976D2),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Text styles
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Color(0xFF1976D2),
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Color(0xFF1565C0),
  );
  
  static const TextStyle bodyText = TextStyle(
    fontSize: 14,
    color: Color(0xFF424242),
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: Color(0xFF757575),
  );
}