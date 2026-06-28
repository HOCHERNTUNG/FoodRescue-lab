import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/listing_model.dart';

class DatabaseSeederService {
  static Future<void> seedDatabase() async {
    final db = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;
    final currentUser = auth.currentUser;

    // 1. Wipe existing listings
    final listingsSnap = await db.collection('listings').get();
    for (var doc in listingsSnap.docs) {
      await doc.reference.delete();
    }

    // 2. Wipe existing reservations (optional, but good for resetting state)
    final reservationsSnap = await db.collection('reservations').get();
    for (var doc in reservationsSnap.docs) {
      await doc.reference.delete();
    }

    // 3. Inject detailed listings (Singapore Coordinates)
    final seedListings = [
      ListingModel(
        id: 'bakery_sunrise',
        name: 'Sunrise Artisan Bakery',
        description: 'Rescued daily baked sourdough breads, croissants, and artisan loaves.',
        category: 'Bakery',
        imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?q=80&w=600&auto=format&fit=crop',
        originalPrice: 15.00,
        discountedPrice: 4.50,
        itemsRemaining: 8,
        pickupWindow: '5:00 PM - 7:00 PM',
        latitude: 1.2795,
        longitude: 103.8496,
        distance: '0.8 km',
      ),
      ListingModel(
        id: 'bakery_sweet',
        name: 'Sweet Tooth Treats',
        description: 'Delicate cakes, chocolate chip cookies, and premium cupcakes.',
        category: 'Bakery',
        imageUrl: 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?q=80&w=600&auto=format&fit=crop',
        originalPrice: 24.00,
        discountedPrice: 7.20,
        itemsRemaining: 3,
        pickupWindow: '6:00 PM - 8:00 PM',
        latitude: 1.3037,
        longitude: 103.9047,
        distance: '2.4 km',
      ),
      ListingModel(
        id: 'deli_city',
        name: 'City Bites Deli',
        description: 'Assorted fresh organic salad greens and surplus produce of the day.',
        category: 'Produce',
        imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?q=80&w=600&auto=format&fit=crop',
        originalPrice: 18.50,
        discountedPrice: 5.00,
        itemsRemaining: 12,
        pickupWindow: '4:00 PM - 6:00 PM',
        latitude: 1.3058,
        longitude: 103.8318,
        distance: '1.5 km',
      ),
    ];

    for (var listing in seedListings) {
      await db.collection('listings').doc(listing.id).set(listing.toMap());
    }

    // 4. Seed User profile details (mealsSaved, totalWeightSaved, aiMessage)
    final Map<String, dynamic> defaultUserData = {
      'name': 'Jane Doe',
      'email': currentUser?.email ?? 'jane.doe@foodrescue.org',
      'mealsSaved': 12,
      'totalWeightSaved': 5.4,
      'aiMessage': 'Jane, your rescued artisan pastry boxes have saved 5.4 kg of organic waste, offsetting 9.7 kg of CO₂ equivalents. You rank #3 in the local neighborhood!',
    };

    // Always seed a fallback default_user document
    await db.collection('users').doc('default_user').set(defaultUserData);

    // If a real user is signed in, seed their uid document too so the dashboard immediately updates
    if (currentUser != null) {
      await db.collection('users').doc(currentUser.uid).set(defaultUserData);
    }
  }
}
