import 'package:flutter/material.dart';

final ColorScheme colorScheme = ColorScheme(
  primary: Color(0xFFFF6A00), // Vibrant orange for primary
  secondary: Color(0xFF1F1F1F), // Dark black-gray for secondary
  surface: Color(0xFF2C2C2C), // Slightly lighter black-gray for surfaces
  error: Color(0xFFD32F2F), // Standard material error red
  onPrimary: Color(0xFFFFFFFF), // White for contrast on primary
  onSecondary: Color(0xFFFFFFFF), // White for contrast on secondary
  onSurface: Color(0xFFFFFFFF), // White for text/icons on surface
  onError: Color(0xFFFFFFFF), // White for contrast on errors
  brightness: Brightness.dark, // Dark theme
);
