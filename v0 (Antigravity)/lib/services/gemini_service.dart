import '../models/reservation.dart';

/// GeminiService defines the contract for our AI Processing Engine.
/// Presentation defense context:
/// - Provides a decoupled contract for AI processing.
/// - Later, we can swap in a live Gemini API client (configured in pubspec.yaml)
///   without editing the visual components.
abstract class GeminiService {
  /// Analyzes the user's list of reservations and returns custom, carbon-conscious tips,
  /// storage guidelines, or recipe ideas based on rescued ingredients.
  Future<String> generateImpactInsights(List<Reservation> reservations);

  /// Performs custom prompt execution (like a chat bot conversation) to help users
  /// figure out what to cook with their specific rescued items.
  Future<String> chatWithAssistant(String message, List<Reservation> reservations);
}
