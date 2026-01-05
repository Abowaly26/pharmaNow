part of 'cart_cubit.dart';

sealed class CartState extends Equatable {
  final CartEntity cartEntity;
  final Set<String> loadingMedicineIds;
  final Set<String> deletingMedicineIds;

  const CartState({
    required this.cartEntity,
    this.loadingMedicineIds = const {},
    this.deletingMedicineIds = const {},
  });

  @override
  List<Object> get props =>
      [cartEntity, loadingMedicineIds, deletingMedicineIds];
}

final class CartInitial extends CartState {
  const CartInitial({
    required super.cartEntity,
    super.loadingMedicineIds,
    super.deletingMedicineIds,
  });
}

final class CartLoading extends CartState {
  const CartLoading({
    required super.cartEntity,
    super.loadingMedicineIds,
    super.deletingMedicineIds,
  });
}

final class CartLoaded extends CartState {
  const CartLoaded({
    required super.cartEntity,
    super.loadingMedicineIds,
    super.deletingMedicineIds,
  });
}

final class CartError extends CartState {
  final String message;

  const CartError({
    required this.message,
    required super.cartEntity,
    super.loadingMedicineIds,
    super.deletingMedicineIds,
  });

  @override
  List<Object> get props =>
      [message, cartEntity, loadingMedicineIds, deletingMedicineIds];
}

final class CartItemAdded extends CartLoaded {
  const CartItemAdded({
    required super.cartEntity,
    super.loadingMedicineIds,
    super.deletingMedicineIds,
  });
}

final class CartItemRemoved extends CartLoaded {
  final CartItemEntity removedItem;

  const CartItemRemoved({
    required this.removedItem,
    required super.cartEntity,
    super.loadingMedicineIds,
    super.deletingMedicineIds,
  });

  @override
  List<Object> get props =>
      [removedItem, cartEntity, loadingMedicineIds, deletingMedicineIds];
}
