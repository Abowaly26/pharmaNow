import 'package:dartz/dartz.dart';
import 'package:pharma_now/core/error/failures.dart';
import 'package:pharma_now/features/home/presentation/ui_model/entities/cart_entity.dart';

/// Abstract class defining the contract for cart-related data operations.
/// This should be implemented by data layer classes that handle cart operations.
abstract class CartRepository {
  /// Retrieves the current user's cart from the data source.
  /// Returns a [CartEntity] on success, or a [Failure] on error.
  Future<Either<Failure, CartEntity>> getCart();

  /// Saves the provided [cart] to the data source.
  /// Returns [unit] on success, or a [Failure] on error.
  Future<Either<Failure, Unit>> saveCart(CartEntity cart);

  /// Clears the current user's cart from the data source.
  /// Returns [unit] on success, or a [Failure] on error.
  Future<Either<Failure, Unit>> clearCart();
}
