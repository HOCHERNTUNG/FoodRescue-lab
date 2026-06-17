import '../models/reservation.dart';

/// ReservationRepository is the abstract interface defining CRUD operations
/// for user food reservations.
/// Presentation defense context:
/// - Screen 3 (Reservations Tracker) will consume this service via Riverpod providers.
/// - Demonstrates clean CRUD architecture by exposing state streams alongside mutation methods.
abstract class ReservationRepository {
  /// Stream to watch all reservations made by a specific user.
  /// Facilitates real-time visual updates of reservation status changes.
  Stream<List<Reservation>> watchReservations(String userId);

  /// CREATE: Save a new reservation transaction to the repository.
  Future<void> createReservation(Reservation reservation);

  /// UPDATE: Change the quantity of items claimed under a reservation.
  Future<void> updateReservationQuantity(String id, int quantity);

  /// UPDATE: Mark the reservation status as completed (claimed at the shop).
  Future<void> completeReservation(String id);

  /// UPDATE: Mark the reservation status as cancelled.
  Future<void> cancelReservation(String id);

  /// DELETE: Remove the reservation transaction from history.
  Future<void> deleteReservation(String id);
}
