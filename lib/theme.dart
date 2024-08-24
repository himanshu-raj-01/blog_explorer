import 'package:flutter/material.dart';

final ThemeData blogExplorerTheme = ThemeData(
  primarySwatch: Colors.blue,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.black),
    bodyLarge: TextStyle(fontSize: 16.0, color: Colors.black87),
  ),
);
