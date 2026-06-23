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
  
  // Extended fields from proposal data dictionary
  final String scheduledTime;
  final bool bringOwnContainer;
  final String pickupNotes;
  final double tipAmount;
  final double amountPaid;
  final DateTime? completedAt;
  final double weightSavedKg;
  final double co2ReducedKg;
  final double waterSavedLiter;
  final double financialSavings;
  final String aiMessage;

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
    this.scheduledTime = '',
    this.bringOwnContainer = false,
    this.pickupNotes = '',
    this.tipAmount = 0.0,
    this.amountPaid = 0.0,
    this.completedAt,
    this.weightSavedKg = 0.0,
    this.co2ReducedKg = 0.0,
    this.waterSavedLiter = 0.0,
    this.financialSavings = 0.0,
    this.aiMessage = '',
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
    String? scheduledTime,
    bool? bringOwnContainer,
    String? pickupNotes,
    double? tipAmount,
    double? amountPaid,
    DateTime? completedAt,
    double? weightSavedKg,
    double? co2ReducedKg,
    double? waterSavedLiter,
    double? financialSavings,
    String? aiMessage,
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
      scheduledTime: scheduledTime ?? this.scheduledTime,
      bringOwnContainer: bringOwnContainer ?? this.bringOwnContainer,
      pickupNotes: pickupNotes ?? this.pickupNotes,
      tipAmount: tipAmount ?? this.tipAmount,
      amountPaid: amountPaid ?? this.amountPaid,
      completedAt: completedAt ?? this.completedAt,
      weightSavedKg: weightSavedKg ?? this.weightSavedKg,
      co2ReducedKg: co2ReducedKg ?? this.co2ReducedKg,
      waterSavedLiter: waterSavedLiter ?? this.waterSavedLiter,
      financialSavings: financialSavings ?? this.financialSavings,
      aiMessage: aiMessage ?? this.aiMessage,
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
      scheduledTime: map['scheduledTime'] ?? '',
      bringOwnContainer: map['bringOwnContainer'] ?? false,
      pickupNotes: map['pickupNotes'] ?? '',
      tipAmount: (map['tipAmount'] as num?)?.toDouble() ?? 0.0,
      amountPaid: (map['amountPaid'] as num?)?.toDouble() ?? 0.0,
      completedAt: map['completedAt'] != null
          ? DateTime.tryParse(map['completedAt'])
          : null,
      weightSavedKg: (map['weightSavedKg'] as num?)?.toDouble() ?? 0.0,
      co2ReducedKg: (map['co2ReducedKg'] as num?)?.toDouble() ?? 0.0,
      waterSavedLiter: (map['waterSavedLiter'] as num?)?.toDouble() ?? 0.0,
      financialSavings: (map['financialSavings'] as num?)?.toDouble() ?? 0.0,
      aiMessage: map['aiMessage'] ?? '',
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
      'scheduledTime': scheduledTime,
      'bringOwnContainer': bringOwnContainer,
      'pickupNotes': pickupNotes,
      'tipAmount': tipAmount,
      'amountPaid': amountPaid,
      'completedAt': completedAt?.toIso8601String(),
      'weightSavedKg': weightSavedKg,
      'co2ReducedKg': co2ReducedKg,
      'waterSavedLiter': waterSavedLiter,
      'financialSavings': financialSavings,
      'aiMessage': aiMessage,
    };
  }
}
