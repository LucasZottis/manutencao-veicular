import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

TextTheme buildTextTheme() {
  final spaceGrotesk = GoogleFonts.spaceGroteskTextTheme();
  final inter = GoogleFonts.interTextTheme();

  return TextTheme(
    displayLarge: spaceGrotesk.displayLarge?.copyWith(color: kOnPrimaryFixed),
    displayMedium: spaceGrotesk.displayMedium?.copyWith(color: kOnPrimaryFixed),
    displaySmall: spaceGrotesk.displaySmall?.copyWith(color: kOnPrimaryFixed),
    headlineLarge: spaceGrotesk.headlineLarge?.copyWith(
      color: kOnPrimaryFixed,
      fontWeight: FontWeight.w700,
    ),
    headlineMedium: spaceGrotesk.headlineMedium?.copyWith(
      color: kOnPrimaryFixed,
      fontWeight: FontWeight.w700,
    ),
    headlineSmall: spaceGrotesk.headlineSmall?.copyWith(
      color: kOnPrimaryFixed,
      fontWeight: FontWeight.w600,
    ),
    titleLarge: spaceGrotesk.titleLarge?.copyWith(
      color: kOnPrimaryFixed,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: spaceGrotesk.titleMedium?.copyWith(
      color: kOnPrimaryFixed,
      fontWeight: FontWeight.w600,
    ),
    titleSmall: spaceGrotesk.titleSmall?.copyWith(color: kOnPrimaryFixed),
    bodyLarge: inter.bodyLarge?.copyWith(color: kOnPrimaryFixed),
    bodyMedium: inter.bodyMedium?.copyWith(color: kOnPrimaryFixed),
    bodySmall: inter.bodySmall?.copyWith(color: kOnSurfaceVariant),
    labelLarge: inter.labelLarge?.copyWith(
      color: kOnPrimaryFixed,
      fontWeight: FontWeight.w600,
    ),
    labelMedium: inter.labelMedium?.copyWith(color: kOnSurfaceVariant),
    labelSmall: inter.labelSmall?.copyWith(
      color: kOnSurfaceVariant,
      letterSpacing: 0.8,
    ),
  );
}
