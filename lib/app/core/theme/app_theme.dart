import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light = ThemeData(
    primaryColor: const Color(0xFF0B630B),
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    fontFamily: 'Roboto',
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF0B630B),
      primary: const Color(0xFF0B630B),
      secondary: const Color(0xFF111261),
    ),
  );
}
