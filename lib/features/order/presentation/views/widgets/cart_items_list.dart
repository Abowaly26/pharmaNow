import 'package:flutter/material.dart';
import 'package:pharma_now/core/widgets/cart_item.dart';
import 'package:pharma_now/features/home/presentation/ui_model/entities/cart_item_entity.dart';

class CartItemsList extends StatelessWidget {
  const CartItemsList({super.key, required this.cartItems});

  final List<CartItemEntity> cartItems;

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: cartItems.length,
      itemBuilder: (context, index) {
        return CartItem(cartItemEntity: cartItems[index]);
      },
    );
  }
}
