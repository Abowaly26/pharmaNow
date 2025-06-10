import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../Cart/presentation/cubits/cart_cubit/cart_cubit.dart';
import '../../features/home/presentation/ui_model/entities/cart_item_entity.dart';
import '../utils/color_manger.dart';
import '../utils/text_styles.dart';

class CartItemActionButtons extends StatelessWidget {
  const CartItemActionButtons({super.key, required this.cartItemEntity});

  final CartItemEntity cartItemEntity;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, dynamic>(
      builder: (context, state) {
        return Row(
          children: [
            CartItemActionButton(
              iconColor: Colors.white,
              icon: Icons.add,
              color: ColorManager.secondaryColor,
              onPressed: () {
                context.read<CartCubit>().updateCartItemQuantity(
                  cartItemEntity,
                  cartItemEntity.count + 1,
                );
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
                if (cartItemEntity.count > 1) {
                  context.read<CartCubit>().updateCartItemQuantity(
                    cartItemEntity,
                    cartItemEntity.count - 1,
                  );
                } else {
                  // If count would be 0, remove the item
                  context.read<CartCubit>().deleteMedicineFromCart(cartItemEntity);
                }
              },
            )
          ],
        );
      },
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
        width: 24.w,
        height: 24.h,
        padding: EdgeInsets.all(
          2.r,
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
