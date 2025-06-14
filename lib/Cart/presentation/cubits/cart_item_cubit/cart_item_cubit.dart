import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pharma_now/features/home/presentation/ui_model/entities/cart_item_entity.dart';

part 'cart_item_state.dart';

class CartItemCubit extends Cubit<CartItemState> {
  CartItemCubit() : super(CartItemInitial());

  void updateCartItem(CartItemEntity cartItemEntity) {
    emit(CartItemUpdated(cartItemEntity: cartItemEntity));
  }
}
