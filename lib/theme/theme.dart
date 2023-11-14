import 'package:flutter/material.dart';

final unfuckYourLifeTheme = ThemeData(
  scaffoldBackgroundColor: Colors.black,
  primaryColor: Colors.black,
  inputDecorationTheme: InputDecorationTheme(
    border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
    hintStyle: TextStyle(
      color: Colors.white.withOpacity(0.7),
    ),
  ),
  colorScheme: const ColorScheme.dark(),
  dialogBackgroundColor: Colors.black,
  useMaterial3: true,
);