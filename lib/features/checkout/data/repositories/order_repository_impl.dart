import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:pharma_now/features/checkout/domain/entites/orderentity.dart';
import 'package:pharma_now/features/checkout/domain/repositories/order_repository.dart';

import '../../../../core/errors/error_handling.dart';

/// Implementation of [OrderRepository] that uses Firestore as the data source.
class OrderRepositoryImpl implements OrderRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  OrderRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? 'unknown';

  // Collection reference for user orders
  CollectionReference get _userOrdersRef =>
      _firestore.collection('users').doc(_userId).collection('orders');

  @override
  Future<Either<Failure, String>> createOrder(OrderEntity order) async {
    try {
      // Add user ID to the order
      final orderWithUserId = order.copyWith(userId: _userId);

      // Convert order to JSON
      final orderData = orderWithUserId.toJson();

      // Add timestamp for Firestore
      orderData['createdAt'] = FieldValue.serverTimestamp();

      // Create the order document
      final docRef = await _userOrdersRef.add(orderData);

      // Also save to a general orders collection for admin access
      await _firestore.collection('orders').doc(docRef.id).set({
        ...orderData,
        'userId': _userId,
        'orderId': docRef.id,
      });

      return Right(docRef.id);
    } catch (e) {
      return Left(ServerFailure('Failed to create order: $e'));
    }
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getUserOrders() async {
    try {
      final querySnapshot =
          await _userOrdersRef.orderBy('createdAt', descending: true).get();

      final orders = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['orderId'] = doc.id; // Add the document ID as orderId
        return OrderEntity.fromJson(data);
      }).toList();

      return Right(orders);
    } catch (e) {
      return Left(ServerFailure('Failed to load orders: $e'));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> getOrderById(String orderId) async {
    try {
      final doc = await _userOrdersRef.doc(orderId).get();

      if (!doc.exists) {
        return Left(ServerFailure('Order not found'));
      }

      final data = doc.data() as Map<String, dynamic>;
      data['orderId'] = doc.id; // Add the document ID as orderId

      final order = OrderEntity.fromJson(data);
      return Right(order);
    } catch (e) {
      return Left(ServerFailure('Failed to load order: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateOrderStatus(
      String orderId, String status) async {
    try {
      await _userOrdersRef.doc(orderId).update({
        'orderStatus': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Also update in the general orders collection
      await _firestore.collection('orders').doc(orderId).update({
        'orderStatus': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Failed to update order status: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteOrder(String orderId) async {
    try {
      await _userOrdersRef.doc(orderId).delete();

      // Also delete from the general orders collection
      await _firestore.collection('orders').doc(orderId).delete();

      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Failed to delete order: $e'));
    }
  }
}
