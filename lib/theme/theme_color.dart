import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

ThemeData? activeTheme;

final mainTheme = ThemeData(
    primaryColor: const Color(0xFF1E232C),
    primaryColorLight: const Color(0xFF1E232C),
    useMaterial3: false,

    appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E232C),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light, // For Android (dark icons)
          statusBarBrightness: Brightness.light, // For iOS (dark icons)
        )),
    primarySwatch: colorBlack,
    brightness: Brightness.light);

MaterialColor colorBlack = const MaterialColor(0xFF1E232C, <int, Color>{
  50: Color(0xFF1E232C),
  100: Color(0xFF1E232C),
  200: Color(0xFF1E232C),
  300: Color(0xFF1E232C),
  400: Color(0xFF1E232C),
  500: Color(0xFF1E232C),
  600: Color(0xFF1E232C),
  700: Color(0xFF1E232C),
  800: Color(0xFF1E232C),
  900: Color(0xFF1E232C),
});
