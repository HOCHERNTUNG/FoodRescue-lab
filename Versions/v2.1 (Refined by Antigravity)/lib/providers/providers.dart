import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reservation_model.dart';
import '../services/gemini_service.dart';
import '../services/mock_gemini_service.dart';

export 'database_providers.dart';

/// Legacy/Compatible UserReservations Stream Provider.
/// Combines active and past reservations into a single stream for general listing views,
/// or watches the reservations collection reactively.
final userReservationsStreamProvider = StreamProvider<List<ReservationModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('reservations')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => ReservationModel.fromFirestore(doc))
          .toList());
});

/// Gemini AI Service Provider.
final geminiServiceProvider = Provider<GeminiService>((ref) {
  return MockGeminiService();
});

/// FutureProvider that feeds generated insights to the dashboard.
/// It watches [userReservationsStreamProvider] and automatically re-generates
/// insights whenever the user's active/past reservations change.
final geminiInsightsProvider = FutureProvider<String>((ref) {
  final geminiService = ref.watch(geminiServiceProvider);
  final reservationsAsync = ref.watch(userReservationsStreamProvider);
  return reservationsAsync.when(
    data: (reservations) => geminiService.generateImpactInsights(reservations),
    loading: () => "Analyzing your eco-contribution...",
    error: (err, _) => "Could not load insights: $err",
  );
});
