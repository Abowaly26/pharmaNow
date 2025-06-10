import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:pharma_now/core/error/failures.dart';
import 'package:pharma_now/features/cart/domain/repositories/cart_repository.dart';
import 'package:pharma_now/features/home/presentation/ui_model/entities/cart_entity.dart';
import 'package:pharma_now/features/home/presentation/ui_model/entities/cart_item_entity.dart';

/// Implementation of [CartRepository] that uses Firestore as the data source.
class CartRepositoryImpl implements CartRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CartRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? 'unknown';
  DocumentReference get _userCartRef => 
      _firestore.collection('users').doc(_userId).collection('cart').doc('items');

  @override
  Future<Either<Failure, CartEntity>> getCart() async {
    try {
      final doc = await _userCartRef.get();
      if (!doc.exists) {
        return Right(CartEntity(cartItems: []));
      }
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null || data['items'] == null) {
        return Right(CartEntity(cartItems: []));
      }
      // Convert Firestore data to CartEntity
      final items = List<Map<String, dynamic>>.from(data['items'] ?? []);
      final cartItems = items.map((item) => CartItemEntity.fromJson(item)).toList();
      return Right(CartEntity(cartItems: cartItems));
    } catch (e) {
      return Left(ServerFailure('Failed to load cart: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveCart(CartEntity cart) async {
    try {
      // Convert cart items to JSON-serializable format
      final itemsJson = cart.cartItems.map((item) => item.toJson()).toList();
      
      await _userCartRef.set({
        'items': itemsJson,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Failed to save cart: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearCart() async {
    try {
      await _userCartRef.delete();
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Failed to clear cart: $e'));
    }
  }
}
