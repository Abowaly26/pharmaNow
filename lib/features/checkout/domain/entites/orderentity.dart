import 'package:pharma_now/features/checkout/domain/entites/shipingadressentity.dart';
import 'package:pharma_now/features/home/presentation/ui_model/entities/cart_entity.dart';
import 'package:pharma_now/features/home/presentation/ui_model/entities/cart_item_entity.dart';

class OrderEntity{

   final List<CartItemEntity>cartItem;
   final bool payWithCash;
   final ShippingAddressEntity shippingAddressEntity;
  OrderEntity(this.cartItem, this.payWithCash, this.shippingAddressEntity);
}