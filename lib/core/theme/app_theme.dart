import 'package:flutter/material.dart';

/// Design tokens and aesthetic configuration for Solunair 3D Weather
class AppTheme {
  AppTheme._();

  // Day Theme Color Palette
  static const Color dayPrimary = Color(0xFF0077B6);
  static const Color dayAccent = Color(0xFFFFB703);
  static const Color daySkyLight = Color(0xFF48CAE4);
  static const Color dayCardSurface = Color(0x33FFFFFF); // 20% opacity white for glass
  static const Color dayCardBorder = Color(0x66FFFFFF);  // 40% opacity white for specular border
  static const Color dayTextPrimary = Color(0xFFFFFFFF);
  static const Color dayTextSecondary = Color(0xCCFFFFFF);

  // Night Theme Color Palette
  static const Color nightPrimary = Color(0xFF1B263B);
  static const Color nightAccent = Color(0xFF7209B7);
  static const Color nightSkyDark = Color(0xFF0D1B2A);
  static const Color nightCardSurface = Color(0x2E1E293B); // Translucent obsidian
  static const Color nightCardBorder = Color(0x3D7209B7);  // Purple-blue specular highlight
  static const Color nightTextPrimary = Color(0xFFF8F9FA);
  static const Color nightTextSecondary = Color(0x99F8F9FA);

  // Accent Colors
  static const Color electricYellow = Color(0xFFFFD166);
  static const Color stormPurple = Color(0xFF8338EC);
  static const Color aquaGlow = Color(0xFF48CAE4);
  static const Color rainBlue = Color(0xFF00B4D8);

  /// 3D Glowing Text Shadow for headings
  static List<Shadow> glowShadows({Color glowColor = const Color(0x80FFFFFF), double blurRadius = 14}) {
    return [
      Shadow(
        color: glowColor,
        blurRadius: blurRadius,
        offset: Offset.zero,
      ),
      const Shadow(
        color: Color(0x66000000),
        blurRadius: 8,
        offset: Offset(0, 3),
      ),
    ];
  }

  /// Ambient Box Shadow for 3D Cards
  static List<BoxShadow> glassBoxShadow({Color glowColor = const Color(0x1A000000)}) {
    return [
      BoxShadow(
        color: glowColor,
        blurRadius: 24,
        spreadRadius: 2,
        offset: const Offset(0, 10),
      ),
      const BoxShadow(
        color: Color(0x1F000000),
        blurRadius: 8,
        offset: Offset(0, 4),
      ),
    ];
  }

  /// Linear gradient for specular 3D borders
  static LinearGradient specularBorderGradient(bool isDay) {
    if (isDay) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0x99FFFFFF),
          Color(0x33FFFFFF),
          Color(0x1AFFFFFF),
          Color(0x66FFFFFF),
        ],
        stops: [0.0, 0.4, 0.7, 1.0],
      );
    } else {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0x8090E0EF),
          Color(0x3348CAE4),
          Color(0x1A7209B7),
          Color(0x668338EC),
        ],
        stops: [0.0, 0.3, 0.7, 1.0],
      );
    }
  }

  /// Standard Material ThemeData for system integration
  static ThemeData buildThemeData({required bool isDark}) {
    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: isDark ? nightSkyDark : const Color(0xFF0F55BD),
      colorScheme: ColorScheme.fromSeed(
        seedColor: isDark ? nightAccent : daySkyLight,
        brightness: isDark ? Brightness.dark : Brightness.light,
      ),
      fontFamily: 'Roboto',
      useMaterial3: true,
    );
  }
}
