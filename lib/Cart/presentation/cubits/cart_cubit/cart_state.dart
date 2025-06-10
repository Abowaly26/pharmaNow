part of 'cart_cubit.dart';

sealed class CartState extends Equatable {
  final CartEntity cartEntity;
  
  const CartState({required this.cartEntity});

  @override
  List<Object> get props => [cartEntity];
}

final class CartInitial extends CartState {
  const CartInitial({required super.cartEntity});
}

final class CartLoading extends CartState {
  const CartLoading({required super.cartEntity});
}

final class CartLoaded extends CartState {
  const CartLoaded({required super.cartEntity});
}

final class CartError extends CartState {
  final String message;
  
  const CartError({
    required this.message,
    required super.cartEntity,
  });

  @override
  List<Object> get props => [message, cartEntity];
}

final class CartItemAdded extends CartLoaded {
  const CartItemAdded({required super.cartEntity});
}

final class CartItemRemoved extends CartLoaded {
  const CartItemRemoved({required super.cartEntity});
}
