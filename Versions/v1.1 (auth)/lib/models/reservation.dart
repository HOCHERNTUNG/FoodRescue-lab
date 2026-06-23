import 'food_item.dart';

/// Reservation tracks items claimed by the user from the surplus food marketplace.
/// Design defense context:
/// - Represents our CRUD domain.
/// - Contains user identifiers, timestamps, specific quantities claimed, status flow control
///   (pending, completed, cancelled), and a generated pickup pin.
/// - Holds an optional embedded `FoodItem` to eliminate complex UI-side joins,
///   enabling clean, high-performance rendering of the Reservations Tracker list.
class Reservation {
  final String id;
  final String foodItemId;
  final String userId;
  final int reservedQuantity;
  final String status; // 'pending', 'completed', 'cancelled'
  final DateTime reservedAt;
  final String pickupCode;
  
  /// Embedded listing representation, facilitating O(1) joins on the client.
  final FoodItem? foodItem;

  const Reservation({
    required this.id,
    required this.foodItemId,
    required this.userId,
    required this.reservedQuantity,
    required this.status,
    required this.reservedAt,
    required this.pickupCode,
    this.foodItem,
  });

  /// Creates a copy of Reservation with optional modifications.
  /// Extremely useful for modifying status or quantities in reactive state managers.
  Reservation copyWith({
    String? id,
    String? foodItemId,
    String? userId,
    int? reservedQuantity,
    String? status,
    DateTime? reservedAt,
    String? pickupCode,
    FoodItem? foodItem,
  }) {
    return Reservation(
      id: id ?? this.id,
      foodItemId: foodItemId ?? this.foodItemId,
      userId: userId ?? this.userId,
      reservedQuantity: reservedQuantity ?? this.reservedQuantity,
      status: status ?? this.status,
      reservedAt: reservedAt ?? this.reservedAt,
      pickupCode: pickupCode ?? this.pickupCode,
      foodItem: foodItem ?? this.foodItem,
    );
  }

  /// Maps standard Firestore/Database map to Reservation instance.
  factory Reservation.fromMap(Map<String, dynamic> map, String docId, {FoodItem? foodItem}) {
    return Reservation(
      id: docId,
      foodItemId: map['foodItemId'] ?? '',
      userId: map['userId'] ?? '',
      reservedQuantity: map['reservedQuantity'] ?? 0,
      status: map['status'] ?? 'pending',
      reservedAt: map['reservedAt'] != null
          ? DateTime.tryParse(map['reservedAt']) ?? DateTime.now()
          : DateTime.now(),
      pickupCode: map['pickupCode'] ?? '',
      foodItem: foodItem,
    );
  }

  /// Converts Reservation to Map structure ready for Firestore database insertion.
  Map<String, dynamic> toMap() {
    return {
      'foodItemId': foodItemId,
      'userId': userId,
      'reservedQuantity': reservedQuantity,
      'status': status,
      'reservedAt': reservedAt.toIso8601String(),
      'pickupCode': pickupCode,
    };
  }
}
