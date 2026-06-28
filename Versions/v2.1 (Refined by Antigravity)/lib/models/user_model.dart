import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final int mealsSaved;
  final double totalWeightSaved;
  final String aiMessage;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.mealsSaved,
    required this.totalWeightSaved,
    required this.aiMessage,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      mealsSaved: (data['mealsSaved'] as num?)?.toInt() ?? 0,
      totalWeightSaved: (data['totalWeightSaved'] as num?)?.toDouble() ?? 0.0,
      aiMessage: data['aiMessage'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'mealsSaved': mealsSaved,
      'totalWeightSaved': totalWeightSaved,
      'aiMessage': aiMessage,
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    int? mealsSaved,
    double? totalWeightSaved,
    String? aiMessage,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      mealsSaved: mealsSaved ?? this.mealsSaved,
      totalWeightSaved: totalWeightSaved ?? this.totalWeightSaved,
      aiMessage: aiMessage ?? this.aiMessage,
    );
  }
}
