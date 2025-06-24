import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FavoritesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Document reference for current user's favorites
  DocumentReference get userFavoritesRef =>
      _firestore.collection('users').doc(currentUserId);

  // Collection of favorites for the current user
  CollectionReference get userFavoritesCollection =>
      userFavoritesRef.collection('favorites');

  // Check if user is logged in
  bool get isUserLoggedIn => currentUserId != null;

  // Check if an item is already in favorites
  Future<bool> isFavorite(String itemId) async {
    if (!isUserLoggedIn) return false;
    try {
      final docSnapshot = await userFavoritesCollection.doc(itemId).get();
      return docSnapshot.exists;
    } catch (e) {
      debugPrint('Error checking favorite status: $e');
      return false;
    }
  }

  // Add item to favorites
  Future<void> addToFavorites({
    required String itemId,
    required Map<String, dynamic> itemData,
  }) async {
    // Check if user is logged in
    if (!isUserLoggedIn) {
      throw Exception('You must be logged in to add items to favorites');
    }
    try {
      // Add additional information to the item, while preserving the original itemData
      final updatedData = {
        ...itemData, // This correctly includes all fields like 'name', 'price', 'quantity', etc.
        'addedAt': FieldValue.serverTimestamp(),
        'userId': currentUserId,
        'code': itemId, // Ensure the code is saved in the data
      };
      // Save item to favorites
      await userFavoritesCollection.doc(itemId).set(updatedData);
    } catch (e) {
      debugPrint('Error adding item to favorites: $e');
      throw Exception('Failed to add item to favorites: $e');
    }
  }

  // Remove item from favorites
  Future<void> removeFromFavorites(String itemId) async {
    if (!isUserLoggedIn) {
      throw Exception('You must be logged in to remove items from favorites');
    }
    try {
      await userFavoritesCollection.doc(itemId).delete();
    } catch (e) {
      debugPrint('Error removing item from favorites: $e');
      throw Exception('Failed to remove item from favorites: $e');
    }
  }

  // Get list of favorites
  Stream<QuerySnapshot> getFavorites() {
    if (!isUserLoggedIn) {
      // Create temporary collection and get empty stream from it
      return FirebaseFirestore.instance
          .collection(
              'temp_empty_collection_${DateTime.now().millisecondsSinceEpoch}')
          .snapshots();
    }
    return userFavoritesCollection
        .orderBy('addedAt', descending: true)
        .snapshots();
  }

  // Toggle favorite status (add or remove)
  Future<bool> toggleFavorite({
    required String itemId,
    required Map<String, dynamic> itemData,
  }) async {
    if (!isUserLoggedIn) {
      throw Exception('User must be logged in');
    }
    try {
      bool isFav = await isFavorite(itemId);
      if (isFav) {
        await removeFromFavorites(itemId);
        return false;
      } else {
        await addToFavorites(itemId: itemId, itemData: itemData);
        return true;
      }
    } catch (e) {
      debugPrint('Error toggling favorite status: $e');
      throw Exception('Failed to toggle favorite status: $e');
    }
  }

  // Get information about a specific favorite item
  Future<DocumentSnapshot?> getFavoriteItem(String itemId) async {
    if (!isUserLoggedIn) return null;
    try {
      return await userFavoritesCollection.doc(itemId).get();
    } catch (e) {
      debugPrint('Error fetching favorite item data: $e');
      return null;
    }
  }

  // Count of favorite items
  Future<int> getFavoritesCount() async {
    if (!isUserLoggedIn) return 0;
    try {
      final snapshot = await userFavoritesCollection.get();
      return snapshot.docs.length;
    } catch (e) {
      debugPrint('Error counting favorites: $e');
      return 0;
    }
  }

  // Delete all favorites
  Future<void> clearAllFavorites() async {
    if (!isUserLoggedIn) {
      throw Exception('You must be logged in to delete favorites');
    }
    try {
      final batch = _firestore.batch();
      final snapshot = await userFavoritesCollection.get();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error deleting all favorites: $e');
      throw Exception('Failed to delete all favorites: $e');
    }
  }

  // Search in favorites
  Stream<QuerySnapshot> searchFavorites(String query) {
    if (!isUserLoggedIn || query.trim().isEmpty) {
      return getFavorites();
    }

    // Convert search to lowercase for comparison
    String searchTerm = query.toLowerCase().trim();

    return userFavoritesCollection
        .orderBy('title') // Assumes there's a "title" field in the data
        .where('title', isGreaterThanOrEqualTo: searchTerm)
        .where('title', isLessThanOrEqualTo: searchTerm + '\uf8ff')
        .snapshots();
  }

  // Create backup of favorites
  Future<Map<String, dynamic>> exportFavorites() async {
    if (!isUserLoggedIn) {
      throw Exception('You must be logged in to export favorites');
    }

    try {
      final snapshot = await userFavoritesCollection.get();
      Map<String, dynamic> favoritesData = {};

      for (var doc in snapshot.docs) {
        favoritesData[doc.id] = doc.data();
      }

      return {
        'userId': currentUserId,
        'exportDate': DateTime.now().toIso8601String(),
        'favorites': favoritesData,
      };
    } catch (e) {
      debugPrint('Error exporting favorites: $e');
      throw Exception('Failed to export favorites: $e');
    }
  }

  // Import backup of favorites
  Future<void> importFavorites(Map<String, dynamic> backupData) async {
    if (!isUserLoggedIn) {
      throw Exception('You must be logged in to import favorites');
    }

    try {
      final batch = _firestore.batch();
      final Map<String, dynamic> favorites =
          backupData['favorites'] as Map<String, dynamic>;

      favorites.forEach((itemId, itemData) {
        final docRef = userFavoritesCollection.doc(itemId);
        batch.set(docRef, {
          ...itemData as Map<String, dynamic>,
          'importedAt': FieldValue.serverTimestamp(),
          'userId': currentUserId,
        });
      });

      await batch.commit();
    } catch (e) {
      debugPrint('Error importing favorites: $e');
      throw Exception('Failed to import favorites: $e');
    }
  }
}
