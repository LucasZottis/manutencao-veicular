import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: kPrimary,
      primaryContainer: kPrimaryContainer,
      surface: kSurface,
      error: kError,
      onPrimary: kSurfaceContainerLowest,
      onSurface: kOnPrimaryFixed,
      onSurfaceVariant: kOnSurfaceVariant,
      tertiary: kTertiary,
      tertiaryContainer: kTertiaryContainer,
      outline: kOutlineVariant,
    ),
    scaffoldBackgroundColor: kSurface,
    textTheme: buildTextTheme(),
    appBarTheme: const AppBarTheme(
      backgroundColor: kSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: kPrimary),
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: kOnPrimaryFixed,
      ),
    ),
    cardTheme: CardTheme(
      color: kSurfaceContainerLowest,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kSurfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        borderSide: const BorderSide(
          color: kPrimary,
          width: 1.5,
        ),
      ),
      labelStyle: const TextStyle(color: kOnSurfaceVariant, fontSize: 12),
      hintStyle: const TextStyle(color: kOnSurfaceVariant),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: kPrimary,
      foregroundColor: kSurfaceContainerLowest,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: kSurfaceContainerLowest,
      selectedItemColor: kPrimary,
      unselectedItemColor: kOnSurfaceVariant,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
  );
}

