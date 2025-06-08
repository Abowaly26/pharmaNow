import 'package:flutter/material.dart';
import 'package:pharma_now/Cart/presentation/cubits/cart_cubit/cart_cubit.dart';
import 'package:provider/provider.dart';

import '../../features/home/presentation/ui_model/entities/cart_item_entity.dart';
import '../utils/color_manger.dart';
import '../utils/text_styles.dart';

class CartItemActionButtons extends StatelessWidget {
  const CartItemActionButtons({super.key, required this.cartItemEntity});

  final CartItemEntity cartItemEntity;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CartItemActionButton(
          iconColor: Colors.white,
          icon: Icons.add,
          color: ColorManager.secondaryColor,
          onPressed: () {
            // cartItemEntity.increasQuantity();
            // context.read<CartItemCubit>().updateCartItem(cartItemEntity);
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            cartItemEntity.count.toString(),
            textAlign: TextAlign.center,
            style: TextStyles.inputLabel,
          ),
        ),
        CartItemActionButton(
          iconColor: ColorManager.textInputColor,
          icon: Icons.remove,
          color: const Color.fromARGB(255, 238, 243, 247),
          onPressed: () {
            // cartItemEntity.decreasQuantity();
            // context.read<CartItemCubit>().updateCartItem(cartItemEntity);
          },
        )
      ],
    );
  }
}

class CartItemActionButton extends StatelessWidget {
  const CartItemActionButton(
      {super.key,
      required this.icon,
      required this.color,
      required this.onPressed,
      required this.iconColor});

  final IconData icon;
  final Color iconColor;
  final Color color;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 24,
        height: 24,
        padding: const EdgeInsets.all(
          2,
        ),
        decoration: ShapeDecoration(
          color: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        child: FittedBox(
          child: Icon(
            icon,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}
