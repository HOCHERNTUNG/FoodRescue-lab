import '../models/reservation_model.dart';

/// GeminiService defines the contract for our AI Processing Engine.
abstract class GeminiService {
  /// Analyzes the user's list of reservations and returns custom, carbon-conscious tips,
  /// storage guidelines, or recipe ideas based on rescued ingredients.
  Future<String> generateImpactInsights(List<ReservationModel> reservations);

  /// Performs custom prompt execution (like a chat bot conversation) to help users
  /// figure out what to cook with their specific rescued items.
  Future<String> chatWithAssistant(String message, List<ReservationModel> reservations);
}
