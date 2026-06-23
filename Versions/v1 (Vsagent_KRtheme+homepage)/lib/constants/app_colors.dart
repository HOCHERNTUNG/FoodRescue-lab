import 'package:flutter/material.dart';

/// AppColors encapsulates the design token palette for the FoodRescue application.
/// In accordance with presentation readiness, each color is chosen to look premium,
/// avoiding basic primary colors, and supporting dark mode out of the box.
class AppColors {
  // Prevent instantiation of utility class
  AppColors._();

  // Core brand colors from stitch design (Kinetic Rescue)
  static const Color primary = Color(0xFFFFD300); // Cyber-Yellow (#FFD300)
  static const Color onPrimary = Color(0xFF000000); // Bold Black for primary text

  static const Color background = Color(0xFFF9F9F9); // surface / background
  static const Color surface = Color(0xFFFFFFFF); // white cards and containers

  // Text tones
  static const Color textPrimary = Color(0xFF1A1C1C); // on-background (very dark charcoal)
  static const Color textSecondary = Color(0xFF333333); // Charcoal Grey for body copy

  // Borders / outlines
  static const Color outline = Color(0xFF7F775F);
  static const Color outlineVariant = Color(0xFFD0C6AB);

  // Backwards-compatible tokens used throughout the app
  static const Color secondary = Color(0xFF5F5E5E); // Charcoal grey (secondary)
  static const Color accent = Color(0xFFF43F5E); // Coral/Rose accent (preserved)
  static const Color border = outlineVariant; // alias for legacy usage
  static const Color mapBlue = Color(0xFF38BDF8); // preserved helper token

  // Support / semantic
  static const Color impactGreen = Color(0xFF34D399); // preserved green accent for success states
  static const Color error = Color(0xFFBA1A1A);

  // Helper tokens referenced elsewhere
  static const Color surfaceTint = Color(0xFF715C00);
}
