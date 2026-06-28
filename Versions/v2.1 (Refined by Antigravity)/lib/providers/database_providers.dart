import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/listing_model.dart';
import '../models/user_model.dart';
import '../models/reservation_model.dart';
import 'auth_provider.dart';

/// listingsStreamProvider: Exposes a Stream<List<ListingModel>> listening to the 'listings' Firestore collection.
final listingsStreamProvider = StreamProvider<List<ListingModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('listings')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => ListingModel.fromFirestore(doc))
          .toList());
});

/// activeReservationsStreamProvider: Exposes a Stream<List<ReservationModel>> reading from 'reservations' where status == 'Active'.
final activeReservationsStreamProvider = StreamProvider<List<ReservationModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('reservations')
      .where('status', isEqualTo: 'Active')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => ReservationModel.fromFirestore(doc))
          .toList());
});

/// pastReservationsStreamProvider: Exposes a Stream<List<ReservationModel>> where status == 'Past'.
final pastReservationsStreamProvider = StreamProvider<List<ReservationModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('reservations')
      .where('status', isEqualTo: 'Past')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => ReservationModel.fromFirestore(doc))
          .toList());
});

/// userProfileStreamProvider: Exposes a Stream<UserModel?> tracking a specific user document ID.
final userProfileStreamProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.value;
  if (user == null) {
    // If no user is logged in, default to the seeded 'default_user' to keep dashboard operating.
    return FirebaseFirestore.instance
        .collection('users')
        .doc('default_user')
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            return UserModel.fromFirestore(doc);
          } else {
            return UserModel(
              uid: 'default_user',
              name: 'Jane Doe',
              email: 'jane.doe@foodrescue.org',
              mealsSaved: 0,
              totalWeightSaved: 0.0,
              aiMessage: 'Welcome to FoodRescue! Click "DEV: SEED DATABASE" in the Profile tab to initialize data.',
            );
          }
        });
  }
  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((doc) {
        if (doc.exists) {
          return UserModel.fromFirestore(doc);
        } else {
          return UserModel(
            uid: user.uid,
            name: user.displayName ?? 'New Rescuer',
            email: user.email ?? 'user@foodrescue.org',
            mealsSaved: 0,
            totalWeightSaved: 0.0,
            aiMessage: 'Welcome to FoodRescue! Click "DEV: SEED DATABASE" below to populate mock data.',
          );
        }
      });
});

/// FirestoreReservationsController manages the CRUD operations in Firestore using transactions.
class FirestoreReservationsController extends StateNotifier<AsyncValue<void>> {
  FirestoreReservationsController() : super(const AsyncData(null));

  /// CREATE Reservation (Reserve Item)
  Future<ReservationModel?> reserveItem(
    ListingModel listing,
    int quantity, {
    String pickupTime = '',
    bool byoContainer = false,
    String userNotes = '',
    double tipAmount = 0.0,
  }) async {
    state = const AsyncLoading();
    try {
      final db = FirebaseFirestore.instance;
      final reservationId = 'res_${DateTime.now().millisecondsSinceEpoch}';
      final totalPaid = (listing.discountedPrice * quantity) + tipAmount;
      final pickupCode = 'FR-${1000 + (DateTime.now().millisecondsSinceEpoch % 9000)}';

      final reservation = ReservationModel(
        id: reservationId,
        listingId: listing.id,
        storeName: listing.name,
        storeImageUrl: listing.imageUrl,
        quantity: quantity,
        totalPaid: totalPaid,
        pickupTime: pickupTime,
        status: 'Active',
        byoContainer: byoContainer,
        userNotes: userNotes,
        createdAt: DateTime.now(),
        pickupCode: pickupCode,
        tipAmount: tipAmount,
      );

      await db.runTransaction((transaction) async {
        final listingRef = db.collection('listings').doc(listing.id);
        final listingDoc = await transaction.get(listingRef);
        if (!listingDoc.exists) {
          throw Exception('Listing not found.');
        }

        final currentRemaining = (listingDoc.data()?['itemsRemaining'] as num?)?.toInt() ?? 0;
        if (currentRemaining < quantity) {
          throw Exception('Insufficient quantity remaining.');
        }

        // 1. Decrement Listing remaining items
        transaction.update(listingRef, {'itemsRemaining': currentRemaining - quantity});

        // 2. Set Reservation document
        final reservationRef = db.collection('reservations').doc(reservationId);
        transaction.set(reservationRef, reservation.toMap());
      });

      state = const AsyncData(null);
      return reservation;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      return null;
    }
  }

  /// UPDATE Reservation
  Future<void> updateReservation(
    ReservationModel oldReservation,
    ReservationModel newReservation,
  ) async {
    state = const AsyncLoading();
    try {
      final db = FirebaseFirestore.instance;
      await db.runTransaction((transaction) async {
        final listingRef = db.collection('listings').doc(newReservation.listingId);
        final listingDoc = await transaction.get(listingRef);
        
        if (listingDoc.exists) {
          final currentRemaining = (listingDoc.data()?['itemsRemaining'] as num?)?.toInt() ?? 0;
          final quantityDiff = newReservation.quantity - oldReservation.quantity;
          
          if (currentRemaining < quantityDiff) {
            throw Exception('Insufficient quantity remaining to update reservation.');
          }

          // Adjust listing itemsRemaining
          transaction.update(listingRef, {'itemsRemaining': currentRemaining - quantityDiff});
        }

        // Save updated reservation
        final reservationRef = db.collection('reservations').doc(newReservation.id);
        transaction.set(reservationRef, newReservation.toMap());
      });
      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  /// DELETE Reservation (Cancel CRUD Action)
  Future<void> cancelReservation(ReservationModel reservation) async {
    state = const AsyncLoading();
    try {
      final db = FirebaseFirestore.instance;
      await db.runTransaction((transaction) async {
        final listingRef = db.collection('listings').doc(reservation.listingId);
        final listingDoc = await transaction.get(listingRef);

        if (listingDoc.exists) {
          final currentRemaining = (listingDoc.data()?['itemsRemaining'] as num?)?.toInt() ?? 0;
          // Refund items back to listing
          transaction.update(listingRef, {'itemsRemaining': currentRemaining + reservation.quantity});
        }

        // Delete reservation record
        final reservationRef = db.collection('reservations').doc(reservation.id);
        transaction.delete(reservationRef);
      });
      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  /// COMPLETE Reservation (Completing/Claiming)
  Future<void> completeReservation(ReservationModel reservation) async {
    state = const AsyncLoading();
    try {
      final db = FirebaseFirestore.instance;
      await db.runTransaction((transaction) async {
        final reservationRef = db.collection('reservations').doc(reservation.id);
        transaction.update(reservationRef, {'status': 'Past'});

        // Also update the User Model's metrics on completion!
        final authUser = FirebaseAuth.instance.currentUser;
        final userDocRef = db.collection('users').doc(authUser?.uid ?? 'default_user');
        final userDoc = await transaction.get(userDocRef);

        int currentMeals = 0;
        double currentWeight = 0.0;
        if (userDoc.exists) {
          currentMeals = (userDoc.data()?['mealsSaved'] as num?)?.toInt() ?? 0;
          currentWeight = (userDoc.data()?['totalWeightSaved'] as num?)?.toDouble() ?? 0.0;
        }

        final addedWeight = reservation.quantity * 0.45; // 0.45kg per portion
        transaction.set(userDocRef, {
          'mealsSaved': currentMeals + reservation.quantity,
          'totalWeightSaved': currentWeight + addedWeight,
          'aiMessage': 'Your latest rescue from ${reservation.storeName} saved ${addedWeight.toStringAsFixed(2)} kg of food, offsetting ${(addedWeight * 1.8).toStringAsFixed(2)} kg of landfill CO₂!',
        }, SetOptions(merge: true));
      });
      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }
}

/// Provider for the FirestoreReservationsController
final firestoreReservationsControllerProvider =
    StateNotifierProvider<FirestoreReservationsController, AsyncValue<void>>((ref) {
  return FirestoreReservationsController();
});
