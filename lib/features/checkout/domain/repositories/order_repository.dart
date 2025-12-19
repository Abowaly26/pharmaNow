import 'package:dartz/dartz.dart';
import 'package:pharma_now/core/errors/error_handling.dart';

import 'package:pharma_now/features/checkout/domain/entites/orderentity.dart';

abstract class OrderRepository {
  /// Create a new order and save it to Firebase
  Future<Either<Failure, String>> createOrder(OrderEntity order);

  /// Get all orders for the current user
  Future<Either<Failure, List<OrderEntity>>> getUserOrders();

  /// Get a specific order by ID
  Future<Either<Failure, OrderEntity>> getOrderById(String orderId);

  /// Update order status
  Future<Either<Failure, Unit>> updateOrderStatus(
      String orderId, String status);

  /// Delete an order
  Future<Either<Failure, Unit>> deleteOrder(String orderId);
}
