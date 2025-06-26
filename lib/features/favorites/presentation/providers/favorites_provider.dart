import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pharma_now/features/favorites/data/services/favorites_service.dart';

class FavoritesProvider extends ChangeNotifier {
  final FavoritesService _favoritesService = FavoritesService();

  // Set to store favorite item IDs for quick use in the UI
  final Set<String> _favoriteIds = {};

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // List of favorite items
  List<Map<String, dynamic>> _favorites = [];
  List<Map<String, dynamic>> get favorites => _favorites;

  // Number of favorite items
  int get favoritesCount => _favoriteIds.length;

  // Firestore changes listener
  StreamSubscription<QuerySnapshot>? _favoritesSubscription;

  FavoritesProvider() {
    _listenToFavorites();
  }

  @override
  void dispose() {
    // Cancel subscription when the provider is disposed
    _favoritesSubscription?.cancel();
    super.dispose();
  }

  // Listen for changes in the favorites list through Firestore
  void _listenToFavorites() {
    _setLoading(true);

    try {
      // Cancel previous subscription if it exists
      _favoritesSubscription?.cancel();

      _favoritesSubscription =
          _favoritesService.getFavorites().listen((QuerySnapshot snapshot) {
        _favorites = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          // Ensure each item contains a code
          return {
            ...data,
            'code': doc.id, // Use document ID as code if it doesn't exist
          };
        }).toList();

        _favoriteIds.clear();

        for (var doc in snapshot.docs) {
          _favoriteIds.add(doc.id);
        }

        _setLoading(false);
        notifyListeners();
      }, onError: (error) {
        debugPrint('Error listening to favorites: $error');
        _setLoading(false);
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Error setting up favorites listener: $e');
      _setLoading(false);
    }
  }

  // Manually refresh favorites
  void refreshFavorites() {
    _listenToFavorites();
  }

  // Check if an item is in favorites
  bool isFavorite(String itemId) {
    return _favoriteIds.contains(itemId);
  }

  // Toggle favorite status (add/remove)
  Future<bool> toggleFavorite({
    required String itemId,
    required Map<String, dynamic> itemData,
  }) async {
    _setLoading(true);
    bool isNowFavorite = false;

    try {
      isNowFavorite = await _favoritesService.toggleFavorite(
        itemId: itemId,
        itemData: itemData,
      );

      // Update the local list for immediate response
      if (isNowFavorite) {
        if (!_favoriteIds.contains(itemId)) {
          _favoriteIds.add(itemId);
          _favorites.add({...itemData, 'code': itemId});
        }
      } else {
        _favoriteIds.remove(itemId);
        _favorites.removeWhere((item) => item['code'] == itemId);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling favorite status: $e');
      rethrow; // Re-throw the error to be caught in the UI
    } finally {
      _setLoading(false);
    }

    return isNowFavorite;
  }

  // Add an item to favorites
  Future<void> addToFavorites({
    required String itemId,
    required Map<String, dynamic> itemData,
  }) async {
    _setLoading(true);

    try {
      await _favoritesService.addToFavorites(
        itemId: itemId,
        itemData: itemData,
      );

      // Update the local list for immediate response
      if (!_favoriteIds.contains(itemId)) {
        _favoriteIds.add(itemId);
        _favorites.add({...itemData, 'code': itemId});
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error adding item to favorites: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Remove an item from favorites
  Future<void> removeFromFavorites(String itemId) async {
    _setLoading(true);

    try {
      // Remove the item from the local list first for immediate UI update
      _favorites.removeWhere((item) => item['code'] == itemId);
      _favoriteIds.remove(itemId);
      notifyListeners();

      // Then remove it from Firebase
      await _favoritesService.removeFromFavorites(itemId);
    } catch (e) {
      debugPrint('Error removing item from favorites: $e');
      // If an error occurs, reload the data
      _listenToFavorites();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Clear all favorites
  Future<void> clearAllFavorites() async {
    _setLoading(true);

    try {
      // Clear local favorites immediately
      _favorites.clear();
      _favoriteIds.clear();
      notifyListeners();

      // Call the service to clear favorites from Firebase
      await _favoritesService.clearAllFavorites();
    } catch (e) {
      debugPrint('Error clearing all favorites: $e');
      // If an error occurs, reload the data
      _listenToFavorites();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
