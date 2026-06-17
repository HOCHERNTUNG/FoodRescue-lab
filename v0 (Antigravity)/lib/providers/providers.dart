import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/food_item.dart';
import '../models/reservation.dart';
import '../services/food_repository.dart';
import '../services/mock_food_repository.dart';
import '../services/reservation_repository.dart';
import '../services/mock_reservation_repository.dart';
import '../services/gemini_service.dart';
import '../services/mock_gemini_service.dart';

/// --- Dependency Injection Layer ---

/// FoodRepository Provider.
/// Design defense context:
/// - Injects the concrete database operations contract.
/// - Currently returns [MockFoodRepository]. To swap to a live Firestore implementation,
///   we only edit this single provider value; no views will need to change.
final foodRepositoryProvider = Provider<FoodRepository>((ref) {
  return MockFoodRepository();
});

/// ReservationRepository Provider.
/// Design defense context:
/// - Injects the concrete CRUD contract for reservations.
/// - Watches [foodRepositoryProvider] to establish cross-service inventory sync.
final reservationRepositoryProvider = Provider<ReservationRepository>((ref) {
  final foodRepository = ref.watch(foodRepositoryProvider);
  return MockReservationRepository(foodRepository);
});


/// --- Reactive State Streaming Layer ---

/// FoodItems Stream Provider.
/// Watches the list of available surplus food items in real-time.
/// Screens like the Marketplace and Map subscribe directly to this provider.
final foodItemsStreamProvider = StreamProvider<List<FoodItem>>((ref) {
  final repository = ref.watch(foodRepositoryProvider);
  return repository.watchFoodItems();
});

/// UserReservations Stream Provider.
/// Watches active and historic reservations for a specific user ID.
/// Screen 3 (Reservations Tracker) subscribes directly to this provider to listen for mutations.
final userReservationsStreamProvider = StreamProvider<List<Reservation>>((ref) {
  final repository = ref.watch(reservationRepositoryProvider);
  // Using a static userId 'user_123' for baseline sandbox demonstration.
  return repository.watchReservations('user_123');
});


/// --- CRUD Business Logic Controller ---

/// ReservationsController handles async operations (creating, updating, completing, canceling)
/// and exposes an [AsyncValue<void>] indicating execution status (loading, error, success).
/// Design defense context:
/// - Provides centralized error and loading state handling for reservations CRUD.
/// - Keeps views free from raw async try/catch blocks, maintaining UI-logic separation.
class ReservationsController extends StateNotifier<AsyncValue<void>> {
  final ReservationRepository _repository;

  ReservationsController(this._repository) : super(const AsyncData(null));

  /// CREATE: Book a food item.
  Future<bool> reserveItem(FoodItem item, int quantity) async {
    state = const AsyncLoading();
    try {
      final reservation = Reservation(
        id: 'res_${DateTime.now().millisecondsSinceEpoch}',
        foodItemId: item.id,
        userId: 'user_123',
        reservedQuantity: quantity,
        status: 'pending',
        reservedAt: DateTime.now(),
        pickupCode: 'FR-${1000 + (DateTime.now().millisecondsSinceEpoch % 9000)}',
      );
      await _repository.createReservation(reservation);
      state = const AsyncData(null);
      return true;
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      return false;
    }
  }

  /// UPDATE: Modify quantity of a reserved item.
  Future<void> updateQuantity(String reservationId, int newQuantity) async {
    state = const AsyncLoading();
    try {
      await _repository.updateReservationQuantity(reservationId, newQuantity);
      state = const AsyncData(null);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }

  /// UPDATE: Complete/Claim reservation.
  Future<void> completeClaim(String reservationId) async {
    state = const AsyncLoading();
    try {
      await _repository.completeReservation(reservationId);
      state = const AsyncData(null);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }

  /// UPDATE: Cancel reservation.
  Future<void> cancelClaim(String reservationId) async {
    state = const AsyncLoading();
    try {
      await _repository.cancelReservation(reservationId);
      state = const AsyncData(null);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }

  /// DELETE: Remove reservation record entirely.
  Future<void> deleteRecord(String reservationId) async {
    state = const AsyncLoading();
    try {
      await _repository.deleteReservation(reservationId);
      state = const AsyncData(null);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }
}

/// Provider for the ReservationsController.
final reservationsControllerProvider = StateNotifierProvider<ReservationsController, AsyncValue<void>>((ref) {
  final repository = ref.watch(reservationRepositoryProvider);
  return ReservationsController(repository);
});

/// --- Gemini AI Processing Layer ---

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
