part of 'cart_cubit.dart';

sealed class CartState extends Equatable {
  final CartEntity cartEntity;
  final Set<String> loadingMedicineIds;

  const CartState({
    required this.cartEntity,
    this.loadingMedicineIds = const {},
  });

  @override
  List<Object> get props => [cartEntity, loadingMedicineIds];
}

final class CartInitial extends CartState {
  const CartInitial({
    required super.cartEntity,
    super.loadingMedicineIds,
  });
}

final class CartLoading extends CartState {
  const CartLoading({
    required super.cartEntity,
    super.loadingMedicineIds,
  });
}

final class CartLoaded extends CartState {
  const CartLoaded({
    required super.cartEntity,
    super.loadingMedicineIds,
  });
}

final class CartError extends CartState {
  final String message;

  const CartError({
    required this.message,
    required super.cartEntity,
    super.loadingMedicineIds,
  });

  @override
  List<Object> get props => [message, cartEntity, loadingMedicineIds];
}

final class CartItemAdded extends CartLoaded {
  const CartItemAdded({
    required super.cartEntity,
    super.loadingMedicineIds,
  });
}

final class CartItemRemoved extends CartLoaded {
  const CartItemRemoved({
    required super.cartEntity,
    super.loadingMedicineIds,
  });
}
