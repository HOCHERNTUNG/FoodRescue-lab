/// FoodItem represents a surplus food listing posted by local businesses.
/// Design defense context:
/// - Includes geolocation coordinates (`latitude`, `longitude`) used directly by `flutter_map`.
/// - Supports JSON/Map serialization which makes swapping the mock repository for
///   live Firebase/Firestore collections trivial and transparent.
class FoodItem {
  final String id;
  final String name;
  final String businessName;
  final String description;
  final double originalPrice;
  final double discountedPrice;
  final int quantity;
  final String pickupWindow;
  final double latitude;
  final double longitude;
  final String category;
  final String imageUrl;

  const FoodItem({
    required this.id,
    required this.name,
    required this.businessName,
    required this.description,
    required this.originalPrice,
    required this.discountedPrice,
    required this.quantity,
    required this.pickupWindow,
    required this.latitude,
    required this.longitude,
    required this.category,
    required this.imageUrl,
  });

  /// Calculates percentage discount for UI presentation.
  int get discountPercentage {
    if (originalPrice <= 0) return 0;
    final discount = ((originalPrice - discountedPrice) / originalPrice) * 100;
    return discount.round();
  }

  /// Creates a copy of FoodItem with optional new values.
  /// Used during state mutation (e.g., decrementing quantity on reservation).
  FoodItem copyWith({
    String? id,
    String? name,
    String? businessName,
    String? description,
    double? originalPrice,
    double? discountedPrice,
    int? quantity,
    String? pickupWindow,
    double? latitude,
    double? longitude,
    String? category,
    String? imageUrl,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      businessName: businessName ?? this.businessName,
      description: description ?? this.description,
      originalPrice: originalPrice ?? this.originalPrice,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      quantity: quantity ?? this.quantity,
      pickupWindow: pickupWindow ?? this.pickupWindow,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  /// Maps a Firestore document or Map object to the FoodItem instance.
  factory FoodItem.fromMap(Map<String, dynamic> map, String docId) {
    return FoodItem(
      id: docId,
      name: map['name'] ?? '',
      businessName: map['businessName'] ?? '',
      description: map['description'] ?? '',
      originalPrice: (map['originalPrice'] as num?)?.toDouble() ?? 0.0,
      discountedPrice: (map['discountedPrice'] as num?)?.toDouble() ?? 0.0,
      quantity: map['quantity'] ?? 0,
      pickupWindow: map['pickupWindow'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      category: map['category'] ?? 'Other',
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  /// Converts the FoodItem to a map for database storage.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'businessName': businessName,
      'description': description,
      'originalPrice': originalPrice,
      'discountedPrice': discountedPrice,
      'quantity': quantity,
      'pickupWindow': pickupWindow,
      'latitude': latitude,
      'longitude': longitude,
      'category': category,
      'imageUrl': imageUrl,
    };
  }
}
