import 'package:flutter/material.dart';

/// Colors and sizes taken from the original app's styles (Tailwind slate,
/// sky and orange scales), rounded to close values.
class Pal {
  static const orange = Color(0xFFFF9600);
  static const orangeTop = Color(0xFFFFA11C);
  static const orangeDeep = Color(0xFFF99300);
  static const orangeBg = Color(0xFFFFF1DB);
  static const blue = Color(0xFF1CB0F6);
  static const blueBg = Color(0xFFE0F2FE);
  static const sky = Color(0xFF0EA5E9);
  static const ink = Color(0xFF0F172A);
  static const slate800 = Color(0xFF1E293B);
  static const slate600 = Color(0xFF475569);
  static const slate = Color(0xFF64748B);
  static const slate400 = Color(0xFF94A3B8);
  static const slate300 = Color(0xFFCBD5E1);
  static const line = Color(0xFFE2E8F0);
  static const slate100 = Color(0xFFF1F5F9);
  static const bg = Color(0xFFF8FAFC);
  static const card = Color(0xFFF7F9FB);
  static const good = Color(0xFF16A34A);
  static const good400 = Color(0xFF4ADE80);
  static const good700 = Color(0xFF15803D);
  static const good50 = Color(0xFFF0FDF4);
  static const good200 = Color(0xFFBBF7D0);
  static const goodBg = Color(0xFFDCFCE7);
  static const bad = Color(0xFFDC2626);
  static const bad400 = Color(0xFFF87171);
  static const bad700 = Color(0xFFB91C1C);
  static const bad50 = Color(0xFFFEF2F2);
  static const bad200 = Color(0xFFFECACA);
  static const badBg = Color(0xFFFFE4E6);
  static const gold = Color(0xFFFFC800);
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: Pal.blue,
    primary: Pal.blue,
    surface: Colors.white,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: Colors.white,
    textTheme: ThemeData.light().textTheme.apply(
      bodyColor: Pal.ink,
      displayColor: Pal.ink,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: Pal.blueBg,
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
      ),
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
  );
}

/// Text styles that follow the original's h1, h2, h3, body and label variants.
class Txt {
  static const h1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: Pal.slate800,
    height: 1.2,
  );
  static const h2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: Pal.slate800,
  );
  static const h3 = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w800,
    color: Pal.slate800,
  );
  static const body = TextStyle(fontSize: 15, color: Pal.slate400, height: 1.4);
  static const bodyDark = TextStyle(
    fontSize: 15,
    color: Pal.slate600,
    height: 1.4,
  );
  static const label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    letterSpacing: 1,
    color: Pal.slate400,
  );
}
