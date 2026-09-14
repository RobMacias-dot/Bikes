import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData get light => _theme(Brightness.light);
  static ThemeData get dark => _theme(Brightness.dark);
  static ThemeData _theme(Brightness brightness) {
    final colors = ColorScheme.fromSeed(
        seedColor: const Color(0xff176c59), brightness: brightness);
    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      scaffoldBackgroundColor: brightness == Brightness.light
          ? const Color(0xfff4f5ef)
          : const Color(0xff111a18),
      appBarTheme: const AppBarTheme(
          centerTitle: false,
          backgroundColor: Colors.transparent,
          elevation: 0),
      cardTheme: CardThemeData(
          margin: EdgeInsets.zero,
          elevation: 1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
      inputDecorationTheme: InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16)),
      filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
              minimumSize: const Size(48, 56),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)))),
    );
  }
}
