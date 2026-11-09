import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  static final light = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.peach,
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: AppColors.brown,
          brightness: Brightness.light,
        ).copyWith(
          surface: AppColors.peach,
          onSurface: AppColors.brown,
          primary: AppColors.brown,
          onPrimary: AppColors.peach,
        ),
    iconTheme: const IconThemeData(color: AppColors.brown),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.brown,
      selectionColor: AppColors.brown,
      selectionHandleColor: AppColors.brown,
    ),

    inputDecorationTheme: InputDecorationTheme(
      helperStyle: const TextStyle(color: AppColors.brown, fontSize: 12),
      filled: true,
      fillColor: AppColors.peach,
      hintStyle: const TextStyle(color: AppColors.brown),
      labelStyle: const TextStyle(color: AppColors.brown),
      floatingLabelStyle: const TextStyle(
        color: AppColors.brown,
        fontWeight: FontWeight.w600,
      ),
      counterStyle: const TextStyle(color: AppColors.brown, fontSize: 12),
      suffixIconColor: AppColors.brown,
      prefixIconColor: AppColors.brown,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.brown, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.brown, width: 2),
      ),

      errorStyle: const TextStyle(
        color: Color(0xFFBA1A1A),
        fontSize: 12,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: Color(0xFFBA1A1A),
          width: 1.2,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: Color(0xFFBA1A1A),
          width: 2,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.brown,
        foregroundColor: AppColors.peach,
        minimumSize: const Size.fromHeight(48),
        shape: const StadiumBorder(),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.brown),
    ),
  );

  static final dark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.brown,
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: AppColors.brown,
          brightness: Brightness.dark,
        ).copyWith(
          surface: AppColors.brown,
          onSurface: AppColors.peach,
          primary: AppColors.peach,
          onPrimary: AppColors.brown,
        ),
    iconTheme: const IconThemeData(color: AppColors.peach),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.peach,
      selectionColor: AppColors.peach,
      selectionHandleColor: AppColors.peach,
    ),
    inputDecorationTheme: InputDecorationTheme(
      helperStyle: const TextStyle(color: AppColors.peach, fontSize: 12),
      filled: true,
      fillColor: AppColors.brown,
      hintStyle: const TextStyle(color: AppColors.peach),
      labelStyle: const TextStyle(color: AppColors.peach),
      floatingLabelStyle: const TextStyle(
        color: AppColors.peach,
        fontWeight: FontWeight.w600,
      ),
      counterStyle: const TextStyle(color: AppColors.peach, fontSize: 12),
      suffixIconColor: AppColors.peach,
      prefixIconColor: AppColors.peach,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.peach, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.peach, width: 2),
      ),

            errorStyle: const TextStyle(
        color: Color(0xFFFFB4AB),
        fontSize: 12,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: Color(0xFFFFB4AB),
          width: 1.2,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: Color(0xFFFFB4AB),
          width: 2,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.peach,
        foregroundColor: AppColors.brown,
        minimumSize: const Size.fromHeight(48),
        shape: const StadiumBorder(),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.peach),
    ),
  );
}
