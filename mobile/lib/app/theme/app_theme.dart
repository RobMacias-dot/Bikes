import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData get light => _theme(Brightness.light);
  static ThemeData get dark => _theme(Brightness.dark);
  static ThemeData _theme(Brightness brightness) => ThemeData(
        useMaterial3: true,
        brightness: brightness,
        colorSchemeSeed: Colors.teal,
        cardTheme: const CardThemeData(margin: EdgeInsets.all(12)),
      );
}
