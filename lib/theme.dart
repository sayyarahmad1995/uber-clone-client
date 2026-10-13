import 'package:flutter/material.dart';
import 'slide_up_transition.dart';

const hiGoPurple = Color(0xFF4834F4);
const hiGoNavy = Color(0xFF111445);
const hiGoBlue = Color(0xFF20278C);
final hiGoTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'Poppins',
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: {
      TargetPlatform.android: SlideUpPageTransitionsBuilder(),
      TargetPlatform.iOS: SlideUpPageTransitionsBuilder(),
      TargetPlatform.macOS: SlideUpPageTransitionsBuilder(),
      TargetPlatform.windows: SlideUpPageTransitionsBuilder(),
      TargetPlatform.linux: SlideUpPageTransitionsBuilder(),
      TargetPlatform.fuchsia: SlideUpPageTransitionsBuilder(),
    },
  ),
  colorScheme: ColorScheme.fromSeed(seedColor: hiGoPurple).copyWith(
    primary: hiGoPurple,
    onPrimary: Colors.white,
    surface: Colors.white,
    onSurface: hiGoNavy,
  ),
  scaffoldBackgroundColor: const Color(0xFFEDEFF7),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(fontSize: 14, color: hiGoNavy),
    bodySmall: TextStyle(fontSize: 12, color: Color(0xFF7D8495)),
  ),
  inputDecorationTheme: InputDecorationTheme(
    isDense: true,
    filled: true,
    fillColor: const Color(0xFFF8F9FD),
    hintStyle: const TextStyle(color: Color(0xFF9299A7), fontSize: 13),
    prefixIconColor: const Color(0xFF9299A7),
    suffixIconColor: const Color(0xFF9299A7),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFD9DCE5)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: hiGoPurple, width: 1.5),
    ),
    errorMaxLines: 3,
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size(double.infinity, 54),
      shape: const StadiumBorder(),
      textStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: hiGoNavy,
      minimumSize: const Size(double.infinity, 54),
      side: const BorderSide(color: Color(0xFFD1D5DF)),
      shape: const StadiumBorder(),
    ),
  ),
  checkboxTheme: CheckboxThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
    side: const BorderSide(color: Color(0xFFCDD2DE), width: 1.5),
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  ),
);
