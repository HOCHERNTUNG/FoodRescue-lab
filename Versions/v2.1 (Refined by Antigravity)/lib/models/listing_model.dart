import 'package:cloud_firestore/cloud_firestore.dart';

class ListingModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final String imageUrl;
  final double originalPrice;
  final double discountedPrice;
  final int itemsRemaining;
  final String pickupWindow;
  final double latitude;
  final double longitude;
  final String distance;

  ListingModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.originalPrice,
    required this.discountedPrice,
    required this.itemsRemaining,
    required this.pickupWindow,
    required this.latitude,
    required this.longitude,
    required this.distance,
  });

  /// Calculates percentage discount for UI presentation.
  int get discountPercentage {
    if (originalPrice <= 0) return 0;
    final discount = ((originalPrice - discountedPrice) / originalPrice) * 100;
    return discount.round().clamp(0, 100);
  }

  factory ListingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ListingModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      originalPrice: (data['originalPrice'] as num?)?.toDouble() ?? 0.0,
      discountedPrice: (data['discountedPrice'] as num?)?.toDouble() ?? 0.0,
      itemsRemaining: (data['itemsRemaining'] as num?)?.toInt() ?? 0,
      pickupWindow: data['pickupWindow'] ?? '',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      distance: data['distance'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'originalPrice': originalPrice,
      'discountedPrice': discountedPrice,
      'itemsRemaining': itemsRemaining,
      'pickupWindow': pickupWindow,
      'latitude': latitude,
      'longitude': longitude,
      'distance': distance,
    };
  }

  ListingModel copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? imageUrl,
    double? originalPrice,
    double? discountedPrice,
    int? itemsRemaining,
    String? pickupWindow,
    double? latitude,
    double? longitude,
    String? distance,
  }) {
    return ListingModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      originalPrice: originalPrice ?? this.originalPrice,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      itemsRemaining: itemsRemaining ?? this.itemsRemaining,
      pickupWindow: pickupWindow ?? this.pickupWindow,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distance: distance ?? this.distance,
    );
  }
}
