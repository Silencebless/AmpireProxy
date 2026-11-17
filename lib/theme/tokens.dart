import 'package:flutter/material.dart';

/// Токены дизайна: цвета сняты с референсных скриншотов, точные значения уточним.
class Tokens {
  static const Color bgTop = Color(0xFF061B2F);
  static const Color bgMid = Color(0xFF02060F);
  static const Color bgBottom = Color(0xFF000000);
  static const Color glass = Color(0xFF1C1D21);
  static const Color edge = Color(0xFF2B2D33);
  static const Color text = Color(0xFFF2F4F8);
  static const Color mute = Color(0xFF8E96A3);
  static const Color blue = Color(0xFF3D8BFF);
  static const Color onBlue = Color(0xFF001B3D);
  static const Color green = Color(0xFF34C759);
  static const Color red = Color(0xFFFF5A5F);
  static const Color disc = Color(0xFF121A24);
  static const Color discEdge = Color(0xFF1E2733);
  static const Color sheet = Color(0xFF15161A);
  static const Color tabActive = Color(0xFF0B0C0E);

  static const TextStyle title =
      TextStyle(fontSize: 32, fontWeight: FontWeight.w300, color: text);
  static const TextStyle body =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: text);
  static const TextStyle caption =
      TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: mute);
}

ThemeData buildTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.black,
    colorScheme: const ColorScheme.dark(
      primary: Tokens.blue,
      surface: Tokens.glass,
    ),
  );
}
