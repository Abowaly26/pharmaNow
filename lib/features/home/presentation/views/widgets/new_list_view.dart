import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/core/enitites/medicine_entity.dart';
import 'package:pharma_now/features/home/presentation/views/widgets/new%20_medicine_list_view_item.dart';

class NewMedicineListView extends StatelessWidget {
  // final int itemCount;
  // final Widget Function(BuildContext, int) itemBuilder;

  final List<MedicineEntity> medicines;

  const NewMedicineListView({
    Key? key,
    required this.medicines,
    // required this.itemCount,
    // required this.itemBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 188.h,
      child: ListView.builder(
          itemCount: medicines.length,
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) => NewMedicineListViewItem(
                index: index,
                isFavorite: false,
                onFavoritePressed: () {},
                medicineEntity: medicines[index],
              )),
    );
  }
}

// Example usage:
// NewProductsList(
//   itemCount: products.length,
//   itemBuilder: (context, index) => NewProductsListViewItem(
//     index: index,
//     isFavorite: true,
//     onFavoritePressed: () {},
//   ),
// )
