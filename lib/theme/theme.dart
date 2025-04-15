import 'package:flutter/material.dart';

final unfuckYourLifeTheme = ThemeData(
  scaffoldBackgroundColor: Colors.black,
  primaryColor: Colors.black,
  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
    hintStyle: TextStyle(
      color: Colors.white,
    ),
  ),

  buttonTheme: const ButtonThemeData(buttonColor: Colors.grey), 

  textTheme: const TextTheme(
      bodyLarge: TextStyle(),
      bodyMedium: TextStyle(),
    ).apply(
      bodyColor: Colors.white, 
      displayColor: Colors.white, 
    ),
    
  appBarTheme: const AppBarTheme(
    color: Colors.black,
  ),
  dialogBackgroundColor: Colors.black,
  useMaterial3: true,
);