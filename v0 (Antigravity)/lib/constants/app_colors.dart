import 'package:flutter/material.dart';

/// AppColors encapsulates the design token palette for the FoodRescue application.
/// In accordance with presentation readiness, each color is chosen to look premium,
/// avoiding basic primary colors, and supporting dark mode out of the box.
class AppColors {
  // Prevent instantiation of utility class
  AppColors._();

  /// Primary Emerald Green representing fresh food, environmental rescue, and sustainability.
  /// Used for major action buttons, active states, and success indicators.
  static const Color primary = Color(0xFF10B981); // Emerald 500

  /// Secondary Warm Amber representing urgency (food expiring soon) and warmth.
  /// Used for badges, warning icons, and high-priority listings.
  static const Color secondary = Color(0xFFF59E0B); // Amber 500

  /// Accent Coral/Rose representing food items count, discounts, or cancellation.
  static const Color accent = Color(0xFFF43F5E); // Rose 500

  /// Primary background color utilizing deep Slate. Provides a sleek, modern, low-strain canvas.
  static const Color background = Color(0xFF0F172A); // Slate 900

  /// Surface color for cards, dialogs, and bottom sheets.
  /// Contrast matches perfectly against the slate background to create depth.
  static const Color surface = Color(0xFF1E293B); // Slate 800

  /// Border and divider color. Subtle enough to be clean, sharp enough to define structure.
  static const Color border = Color(0xFF334155); // Slate 700

  /// Text colors hierarchy:
  /// Primary white-slate for maximum readability.
  static const Color textPrimary = Color(0xFFF8FAFC); // Slate 50

  /// Secondary muted-slate for metadata, labels, and helper descriptions.
  static const Color textSecondary = Color(0xFF94A3B8); // Slate 400

  /// Highlight green for positive impact numbers (CO2 saved, money saved).
  static const Color impactGreen = Color(0xFF34D399); // Emerald 400
  
  /// Highlight blue for discovery actions and maps.
  static const Color mapBlue = Color(0xFF38BDF8); // Sky 400
}
