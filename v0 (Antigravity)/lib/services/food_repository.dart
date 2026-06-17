import '../models/food_item.dart';

/// FoodRepository is the abstract interface defining how our application reads
/// surplus food listings from the database layer.
/// Presentation defense context:
/// - By using an abstract class rather than directly querying Firebase, the UI
///   components depend solely on these method contracts.
/// - Later, we can swap in a live Firestore-backed implementation in providers.dart
///   without editing any screen files.
abstract class FoodRepository {
  /// Watches (streams) all active food items from the data source.
  /// Streams enable real-time UI updates when listings are added or purchased.
  Stream<List<FoodItem>> watchFoodItems();

  /// Fetches a single food item by its ID.
  Future<FoodItem?> getFoodItem(String id);

  /// Helper method to simulate decrementing quantity in stock upon booking.
  Future<void> updateFoodItemQuantity(String id, int newQuantity);
}
