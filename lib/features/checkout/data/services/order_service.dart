import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pharma_now/features/checkout/domain/entites/orderentity.dart';
import 'package:pharma_now/features/checkout/domain/entites/shipingadressentity.dart';
import 'package:pharma_now/features/home/presentation/ui_model/entities/cart_item_entity.dart';
import 'package:pharma_now/core/services/notification_service.dart';
import 'package:pharma_now/features/checkout/presentation/views/order_history_view.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Check if user is logged in
  bool get isUserLoggedIn => currentUserId != null;

  Future<String> createOrderFromCart({
    required List<CartItemEntity> cartItems,
    required bool payWithCash,
    required ShippingAddressEntity shippingAddress,
    required double subtotal,
    required double deliveryFee,
    required double totalAmount,
    String? paymentProofUrl,
    String? prescriptionUrl,
    String? paymentMethodName,
    String? senderWalletPhone,
    String? pharmacyWalletNumber,
  }) async {
    if (!isUserLoggedIn) {
      throw Exception('You must be logged in to create an order');
    }

    try {
      // Create order entity
      final order = OrderEntity(
        cartItem: cartItems,
        payWithCash: payWithCash,
        shippingAddressEntity: shippingAddress,
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        totalAmount: totalAmount,
        userId: currentUserId,
        paymentProofUrl: paymentProofUrl,
        prescriptionUrl: prescriptionUrl,
        paymentMethodName: paymentMethodName,
        senderWalletPhone: senderWalletPhone,
        pharmacyWalletNumber: pharmacyWalletNumber,
      );

      // Map user ID to the order
      final orderWithUserId = order.copyWith(userId: currentUserId);

      // Convert order to JSON
      final orderData = orderWithUserId.toJson();

      // Add Firestore timestamp
      orderData['createdAt'] = FieldValue.serverTimestamp();
      orderData['updatedAt'] = FieldValue.serverTimestamp();

      // Save to user's orders collection
      final userOrdersRef = _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('orders');

      // Generate a new document reference to get the ID first
      final docRef = userOrdersRef.doc();
      orderData['orderId'] = docRef.id; // Store the ID in the document

      // Also ensure the order entity's orderId field is set in JSON
      // (toJson might have it as null if the entity didn't have it)

      await docRef.set(orderData);

      // Also save to general orders collection for admin access
      await _firestore.collection('orders').doc(docRef.id).set({
        ...orderData,
        'userId': currentUserId,
        'orderId': docRef.id,
      });

      // Clear the cart after successful order creation
      await _clearUserCart();

      // Trigger local notification
      NotificationService.instance.showSystemNotification(
        title: 'Order Received! 🎉',
        body:
            'Thank you for your order! Our team will contact you shortly to confirm details and delivery time.',
        type: 'order',
        route: OrderHistoryView.routeName,
      );

      return docRef.id;
    } catch (e) {
      debugPrint('Error creating order: $e');
      throw Exception('Failed to create order: $e');
    }
  }

  /// Get all orders for the current user
  Stream<QuerySnapshot> getUserOrders() {
    if (!isUserLoggedIn) {
      // Return empty stream if not logged in
      return FirebaseFirestore.instance
          .collection(
              'temp_empty_collection_${DateTime.now().millisecondsSinceEpoch}')
          .snapshots();
    }

    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Get a specific order by ID
  Future<Map<String, dynamic>?> getOrderById(String orderId) async {
    if (!isUserLoggedIn) {
      throw Exception('You must be logged in to view orders');
    }

    try {
      final doc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('orders')
          .doc(orderId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['orderId'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting order: $e');
      throw Exception('Failed to get order: $e');
    }
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    if (!isUserLoggedIn) {
      throw Exception('You must be logged in to update orders');
    }

    try {
      final updateData = {
        'orderStatus': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Update in user's orders collection
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('orders')
          .doc(orderId)
          .update(updateData);

      // Also update in general orders collection
      await _firestore.collection('orders').doc(orderId).update(updateData);
    } catch (e) {
      debugPrint('Error updating order status: $e');
      throw Exception('Failed to update order status: $e');
    }
  }

  /// Delete an order
  Future<void> deleteOrder(String orderId) async {
    if (!isUserLoggedIn) {
      throw Exception('You must be logged in to delete orders');
    }

    try {
      // Delete from user's orders collection
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('orders')
          .doc(orderId)
          .delete();

      // Also delete from general orders collection
      await _firestore.collection('orders').doc(orderId).delete();
    } catch (e) {
      debugPrint('Error deleting order: $e');
      throw Exception('Failed to delete order: $e');
    }
  }

  /// Clear user's cart after successful order
  Future<void> _clearUserCart() async {
    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('cart')
          .doc('items')
          .delete();
    } catch (e) {
      debugPrint('Error clearing cart: $e');
      // Don't throw here as the order was already created successfully
    }
  }

  /// Get order statistics for the current user
  Future<Map<String, dynamic>> getUserOrderStats() async {
    if (!isUserLoggedIn) {
      return {
        'totalOrders': 0,
        'totalSpent': 0.0,
        'pendingOrders': 0,
        'completedOrders': 0,
      };
    }

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('orders')
          .get();

      int totalOrders = 0;
      double totalSpent = 0.0;
      int pendingOrders = 0;
      int completedOrders = 0;

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        totalOrders++;
        totalSpent += (data['totalAmount'] ?? 0.0).toDouble();

        final status = data['orderStatus'] ?? 'pending';
        if (status == 'pending') {
          pendingOrders++;
        } else if (status == 'completed') {
          completedOrders++;
        }
      }

      return {
        'totalOrders': totalOrders,
        'totalSpent': totalSpent,
        'pendingOrders': pendingOrders,
        'completedOrders': completedOrders,
      };
    } catch (e) {
      debugPrint('Error getting order stats: $e');
      return {
        'totalOrders': 0,
        'totalSpent': 0.0,
        'pendingOrders': 0,
        'completedOrders': 0,
      };
    }
  }
}
