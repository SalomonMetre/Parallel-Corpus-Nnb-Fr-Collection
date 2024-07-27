import 'package:flutter/material.dart';

final appThemeData = ThemeData(
  primarySwatch: Colors.teal,
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.white,
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: Colors.teal,
    onPrimary: Colors.white,
    secondary: Colors.green,
    onSecondary: Colors.yellow,
    error: Colors.red,
    onError: Colors.white,
    surface: Colors.white,
    onSurface: Colors.teal,
  ),
  textTheme: const TextTheme(
    titleSmall: TextStyle(color: Colors.teal),
    headlineMedium: TextStyle(color: Colors.teal),
    bodyMedium: TextStyle(color: Colors.teal),
    displayMedium: TextStyle(color: Colors.teal),
    labelMedium: TextStyle(color: Colors.teal),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    hintStyle: TextStyle(color: Colors.teal),
  ),
);
