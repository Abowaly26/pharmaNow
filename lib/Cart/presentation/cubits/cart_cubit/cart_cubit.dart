import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pharma_now/features/home/presentation/ui_model/entities/cart_entity.dart';
import 'package:pharma_now/features/home/presentation/ui_model/entities/cart_item_entity.dart';

import '../../../../core/enitites/medicine_entity.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartInitial());

  CartEntity cartEntity = CartEntity(cartItems: []);

  void addMedicineToCart(MedicineEntity medicineEntity) {
    bool isMedicineExist = cartEntity.isExist(medicineEntity);
    var cartItemEntity = cartEntity.getCartItem(medicineEntity);

    if (isMedicineExist) {
      cartItemEntity.increaseCount();
    } else {
      cartEntity.addCartItem(cartItemEntity);
    }
    emit(CartMedicineAdded());
  }
}
