// theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Primary brand color
  static const Color primaryColor = Color(0xFF3F51B5);

  // Light theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true, // For modern Material 3 styling
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        fixedSize: WidgetStateProperty.all<Size>(const Size(250.0, 50)),
        backgroundColor: WidgetStateProperty.all<Color>(primaryColor),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28.0),
        )),
        foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
        side: WidgetStateProperty.all<BorderSide>(
            const BorderSide(color: Colors.white, width: 2.0)),
      )
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 16, color: Colors.black),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.black87),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(fontSize: 10),
    ),
    inputDecorationTheme: InputDecorationTheme(
      // filled: true,
      // fillColor:const Color(0xFFF8FFF4), // background color
      isDense: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(
          color: Colors.black54,
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(
          color: Color(0xFF3F51B5),
          width: 2,
        ),
      ),
      labelStyle: const TextStyle(
        color: Colors.black87,
        fontSize: 16,
      ),
      hintStyle: const TextStyle(
        color: Colors.grey,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
    ),

  );
}
