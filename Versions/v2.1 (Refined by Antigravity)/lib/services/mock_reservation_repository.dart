import 'dart:async';
import '../models/reservation.dart';
import 'food_repository.dart';
import 'reservation_repository.dart';

/// MockReservationRepository manages reservations in-memory.
/// Presentation defense context:
/// - Maintains a stateful list of reservations.
/// - Injected with [FoodRepository] to coordinate and synchronize listing quantities
///   during CRUD interactions (e.g. reserving items decrements stock, canceling increments it).
/// - Broadcasts all mutations instantly using a broadcast StreamController.
class MockReservationRepository implements ReservationRepository {
  final FoodRepository _foodRepository;

  // Stateful list of reservations. Pre-populated with records to immediately show data.
  final List<Reservation> _reservations = [];

  // StreamController to broadcast reservation state modifications.
  final StreamController<List<Reservation>> _controller = StreamController<List<Reservation>>.broadcast();

  MockReservationRepository(this._foodRepository) {
    _initMockReservations();
  }

  /// Populate with pre-cooked records representing distinct phases (Pending, Completed, Cancelled).
  void _initMockReservations() async {
    // We fetch current items to link inside our initial mock reservations.
    final itemsStream = _foodRepository.watchFoodItems();
    final firstItems = await itemsStream.first;

    if (firstItems.isNotEmpty) {
      _reservations.addAll([
        Reservation(
          id: 'res_1',
          foodItemId: firstItems[0].id,
          userId: 'user_123',
          reservedQuantity: 2,
          status: 'pending',
          reservedAt: DateTime.now().subtract(const Duration(hours: 2)),
          pickupCode: 'FR-8821',
          scheduledTime: '5:30 PM',
          bringOwnContainer: true,
          pickupNotes: 'Requesting eco-bags if possible.',
          tipAmount: 1.00,
          amountPaid: (firstItems[0].discountedPrice * 2) + 1.00,
          weightSavedKg: 0.90,
          co2ReducedKg: 1.62,
          waterSavedLiter: 6.0,
          financialSavings: (firstItems[0].originalPrice - firstItems[0].discountedPrice) * 2,
          aiMessage: 'Your pending rescue from Green Garden Cafe will save 0.90 kg of food, reducing greenhouse gas emissions by 1.62 kg of CO2 equivalent.',
          foodItem: firstItems[0],
        ),
        Reservation(
          id: 'res_2',
          foodItemId: firstItems[1].id,
          userId: 'user_123',
          reservedQuantity: 1,
          status: 'completed',
          reservedAt: DateTime.now().subtract(const Duration(days: 1)),
          pickupCode: 'FR-4109',
          scheduledTime: '7:00 PM',
          bringOwnContainer: false,
          pickupNotes: '',
          tipAmount: 0.00,
          amountPaid: firstItems[1].discountedPrice,
          completedAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
          weightSavedKg: 0.45,
          co2ReducedKg: 0.81,
          waterSavedLiter: 3.0,
          financialSavings: firstItems[1].originalPrice - firstItems[1].discountedPrice,
          aiMessage: 'Rescued croissant box from Baker Street Delights successfully! This single rescue offset 0.81 kg of landfill CO2.',
          foodItem: firstItems[1],
        ),
        Reservation(
          id: 'res_3',
          foodItemId: firstItems[2].id,
          userId: 'user_123',
          reservedQuantity: 1,
          status: 'cancelled',
          reservedAt: DateTime.now().subtract(const Duration(days: 3)),
          pickupCode: 'FR-9903',
          scheduledTime: '8:30 PM',
          bringOwnContainer: true,
          pickupNotes: '',
          tipAmount: 2.00,
          amountPaid: firstItems[2].discountedPrice + 2.00,
          weightSavedKg: 0.45,
          co2ReducedKg: 0.81,
          waterSavedLiter: 3.0,
          financialSavings: firstItems[2].originalPrice - firstItems[2].discountedPrice,
          aiMessage: 'This reservation was cancelled, returning stock to Zen Fusion & Sushi.',
          foodItem: firstItems[2],
        ),
      ]);
      _broadcast();
    }
  }

  void _broadcast() {
    _controller.add(List.unmodifiable(_reservations));
  }

  @override
  Stream<List<Reservation>> watchReservations(String userId) {
    // Return stream filtered for the matching user.
    _broadcast();
    return _controller.stream.map(
      (list) => list.where((res) => res.userId == userId).toList(),
    );
  }

  @override
  Future<void> createReservation(Reservation reservation) async {
    await Future.delayed(const Duration(milliseconds: 150)); // Network simulation

    // Fetch details of the listing to embed it.
    final foodItem = await _foodRepository.getFoodItem(reservation.foodItemId);
    if (foodItem == null) throw Exception("Listing not found.");
    if (foodItem.quantity < reservation.reservedQuantity) {
      throw Exception("Insufficient stock available.");
    }

    // Decrement the stock in the food repository.
    await _foodRepository.updateFoodItemQuantity(
      reservation.foodItemId,
      foodItem.quantity - reservation.reservedQuantity,
    );

    // Save with embedded food item.
    final newRes = reservation.copyWith(foodItem: foodItem);
    _reservations.insert(0, newRes); // Insert at top of list
    _broadcast();
  }

  @override
  Future<void> updateReservationQuantity(String id, int quantity) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _reservations.indexWhere((res) => res.id == id);
    if (index == -1) return;

    final reservation = _reservations[index];
    final foodItem = await _foodRepository.getFoodItem(reservation.foodItemId);
    if (foodItem == null) return;

    // Calculate difference in quantity to update listing inventory.
    final diff = quantity - reservation.reservedQuantity;
    if (foodItem.quantity < diff) {
      throw Exception("Insufficient stock available to update reservation.");
    }

    // Adjust food listing quantities.
    await _foodRepository.updateFoodItemQuantity(
      reservation.foodItemId,
      foodItem.quantity - diff,
    );

    // Update reservation state.
    _reservations[index] = reservation.copyWith(
      reservedQuantity: quantity,
      foodItem: foodItem.copyWith(quantity: foodItem.quantity - diff),
    );
    _broadcast();
  }

  @override
  Future<void> updateReservationPickupTime(String id, String newTime) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _reservations.indexWhere((res) => res.id == id);
    if (index != -1) {
      _reservations[index] = _reservations[index].copyWith(scheduledTime: newTime);
      _broadcast();
    }
  }

  @override
  Future<void> completeReservation(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _reservations.indexWhere((res) => res.id == id);
    if (index != -1) {
      _reservations[index] = _reservations[index].copyWith(status: 'completed');
      _broadcast();
    }
  }

  @override
  Future<void> cancelReservation(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _reservations.indexWhere((res) => res.id == id);
    if (index == -1) return;

    final reservation = _reservations[index];
    if (reservation.status == 'cancelled') return;

    // Refund stock to listing.
    final foodItem = await _foodRepository.getFoodItem(reservation.foodItemId);
    if (foodItem != null) {
      await _foodRepository.updateFoodItemQuantity(
        reservation.foodItemId,
        foodItem.quantity + reservation.reservedQuantity,
      );
    }

    _reservations[index] = reservation.copyWith(status: 'cancelled');
    _broadcast();
  }

  @override
  Future<void> deleteReservation(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _reservations.indexWhere((res) => res.id == id);
    if (index == -1) return;

    final reservation = _reservations[index];
    // If deleted while pending, refund the stock first.
    if (reservation.status == 'pending') {
      final foodItem = await _foodRepository.getFoodItem(reservation.foodItemId);
      if (foodItem != null) {
        await _foodRepository.updateFoodItemQuantity(
          reservation.foodItemId,
          foodItem.quantity + reservation.reservedQuantity,
        );
      }
    }

    _reservations.removeAt(index);
    _broadcast();
  }
}
