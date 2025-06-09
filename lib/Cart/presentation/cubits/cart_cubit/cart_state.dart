part of 'cart_cubit.dart';

sealed class CartState extends Equatable {
  const CartState();

  @override
  List<Object> get props => [];
}

final class CartInitial extends CartState {
  final CartEntity cartEntity;
  const CartInitial({required this.cartEntity});

  @override
  List<Object> get props => [cartEntity];
}

final class CartLoaded extends CartState {
  final CartEntity cartEntity;
  const CartLoaded({required this.cartEntity});

  @override
  List<Object> get props => [cartEntity];
}

final class CartItemAdded extends CartLoaded {
  const CartItemAdded({required super.cartEntity});
}

final class CartItemRemoved extends CartLoaded {
  const CartItemRemoved({required super.cartEntity});
}
