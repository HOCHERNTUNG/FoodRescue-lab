import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationModel {
  final String id;
  final String listingId;
  final String storeName;
  final String storeImageUrl;
  final int quantity;
  final double totalPaid;
  final String pickupTime;
  final String status; // 'Active' or 'Past'
  final bool byoContainer;
  final String userNotes;
  final DateTime createdAt;
  final String pickupCode;
  final double tipAmount;

  ReservationModel({
    required this.id,
    required this.listingId,
    required this.storeName,
    required this.storeImageUrl,
    required this.quantity,
    required this.totalPaid,
    required this.pickupTime,
    required this.status,
    required this.byoContainer,
    required this.userNotes,
    required this.createdAt,
    required this.pickupCode,
    required this.tipAmount,
  });

  factory ReservationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    DateTime parsedDate;
    if (data['createdAt'] is Timestamp) {
      parsedDate = (data['createdAt'] as Timestamp).toDate();
    } else if (data['createdAt'] is String) {
      parsedDate = DateTime.tryParse(data['createdAt']) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return ReservationModel(
      id: doc.id,
      listingId: data['listingId'] ?? '',
      storeName: data['storeName'] ?? '',
      storeImageUrl: data['storeImageUrl'] ?? '',
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      totalPaid: (data['totalPaid'] as num?)?.toDouble() ?? 0.0,
      pickupTime: data['pickupTime'] ?? '',
      status: data['status'] ?? 'Active',
      byoContainer: data['byoContainer'] as bool? ?? false,
      userNotes: data['userNotes'] ?? '',
      createdAt: parsedDate,
      pickupCode: data['pickupCode'] ?? '',
      tipAmount: (data['tipAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'listingId': listingId,
      'storeName': storeName,
      'storeImageUrl': storeImageUrl,
      'quantity': quantity,
      'totalPaid': totalPaid,
      'pickupTime': pickupTime,
      'status': status,
      'byoContainer': byoContainer,
      'userNotes': userNotes,
      'createdAt': Timestamp.fromDate(createdAt),
      'pickupCode': pickupCode,
      'tipAmount': tipAmount,
    };
  }

  ReservationModel copyWith({
    String? id,
    String? listingId,
    String? storeName,
    String? storeImageUrl,
    int? quantity,
    double? totalPaid,
    String? pickupTime,
    String? status,
    bool? byoContainer,
    String? userNotes,
    DateTime? createdAt,
    String? pickupCode,
    double? tipAmount,
  }) {
    return ReservationModel(
      id: id ?? this.id,
      listingId: listingId ?? this.listingId,
      storeName: storeName ?? this.storeName,
      storeImageUrl: storeImageUrl ?? this.storeImageUrl,
      quantity: quantity ?? this.quantity,
      totalPaid: totalPaid ?? this.totalPaid,
      pickupTime: pickupTime ?? this.pickupTime,
      status: status ?? this.status,
      byoContainer: byoContainer ?? this.byoContainer,
      userNotes: userNotes ?? this.userNotes,
      createdAt: createdAt ?? this.createdAt,
      pickupCode: pickupCode ?? this.pickupCode,
      tipAmount: tipAmount ?? this.tipAmount,
    );
  }
}
