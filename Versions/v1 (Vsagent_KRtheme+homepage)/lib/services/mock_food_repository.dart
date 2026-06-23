import 'dart:async';
import '../models/food_item.dart';
import 'food_repository.dart';

/// MockFoodRepository implements FoodRepository, managing listings in-memory.
/// Design defense context:
/// - To prevent database failures or internet issues from interrupting UI reviews,
///   this repository manages a hardcoded set of high-quality items.
/// - We use a stream controller to broadcast modifications, mimicking the behavior
///   of real-time databases (like Firestore streams).
/// - Coordinates are set in San Francisco, matching our discovery map view center.
class MockFoodRepository implements FoodRepository {
  // Hardcoded in-memory state of available surplus foods.
  final List<FoodItem> _items = [
    FoodItem(
      id: 'food_1',
      name: 'Organic Avocado & Sourdough Toast Box',
      businessName: 'Green Garden Cafe',
      description: 'Contains 3 portions of freshly prepared avocado toast on organic sourdough, packaged in eco-friendly boxes. Perfect for breakfast or lunch!',
      originalPrice: 18.50,
      discountedPrice: 6.00,
      quantity: 4,
      pickupWindow: '5:00 PM - 7:00 PM',
      latitude: 37.7749,
      longitude: -122.4194,
      category: 'Meals',
      imageUrl: 'https://images.unsplash.com/photo-1541532713592-79a0317b6b77?w=500&q=80',
    ),
    FoodItem(
      id: 'food_2',
      name: 'Assorted Gourmet Pastries',
      businessName: 'Baker Street Delights',
      description: 'A box of 5 freshly baked pastries including croissants, pain au chocolat, and danishes. Saved from today\'s display counter.',
      originalPrice: 15.00,
      discountedPrice: 5.00,
      quantity: 6,
      pickupWindow: '6:30 PM - 8:30 PM',
      latitude: 37.7833,
      longitude: -122.4167,
      category: 'Bakery',
      imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=500&q=80',
    ),
    FoodItem(
      id: 'food_3',
      name: 'Vegan Sushi Combo Box',
      businessName: 'Zen Fusion & Sushi',
      description: 'Delicious selection of cucumber rolls, avocado rolls, and sweet tofu nigiri. Prepared fresh this afternoon.',
      originalPrice: 22.00,
      discountedPrice: 8.50,
      quantity: 3,
      pickupWindow: '8:00 PM - 9:30 PM',
      latitude: 37.7699,
      longitude: -122.4468,
      category: 'Meals',
      imageUrl: 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=500&q=80',
    ),
    FoodItem(
      id: 'food_4',
      name: 'Artisan Cheese & Charcuterie Pack',
      businessName: 'The Grapevine Cellars',
      description: 'Curated selection of soft and hard cheeses, cured meats, dried figs, and crackers. Ideal for sharing.',
      originalPrice: 28.00,
      discountedPrice: 12.00,
      quantity: 2,
      pickupWindow: '4:00 PM - 6:00 PM',
      latitude: 37.7892,
      longitude: -122.4014,
      category: 'Groceries',
      imageUrl: 'https://images.unsplash.com/photo-1540360701408-5ad996848d1d?w=500&q=80',
    ),
    FoodItem(
      id: 'food_5',
      name: 'Fresh Organic Produce Box',
      businessName: 'Market Hall Grocers',
      description: 'A mix of organic bell peppers, baby spinach, heirloom tomatoes, and apples that are slightly imperfect in size but perfectly fresh and delicious.',
      originalPrice: 20.00,
      discountedPrice: 7.00,
      quantity: 5,
      pickupWindow: '3:00 PM - 6:00 PM',
      latitude: 37.7599,
      longitude: -122.4348,
      category: 'Produce',
      imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=500&q=80',
    ),
  ];

  /// The StreamController allows multiple subscribers to receive real-time updates.
  final StreamController<List<FoodItem>> _controller = StreamController<List<FoodItem>>.broadcast();

  MockFoodRepository() {
    // Initial broadcast of food items to the stream.
    _broadcast();
  }

  void _broadcast() {
    _controller.add(List.unmodifiable(_items));
  }

  @override
  Stream<List<FoodItem>> watchFoodItems() {
    // We broadcast immediately upon subscription to populate UI lists instantly.
    _broadcast();
    return _controller.stream;
  }

  @override
  Future<FoodItem?> getFoodItem(String id) async {
    // Simulating database network delay of 100ms
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> updateFoodItemQuantity(String id, int newQuantity) async {
    // Simulating network delay
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      if (newQuantity < 0) return;
      _items[index] = _items[index].copyWith(quantity: newQuantity);
      _broadcast();
    }
  }
}
