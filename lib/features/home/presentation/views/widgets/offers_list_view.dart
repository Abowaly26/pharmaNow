import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/features/home/presentation/views/widgets/offers_list_view_item.dart';

import '../../../../../core/enitites/medicine_entity.dart';

class OffersListView extends StatelessWidget {
  // final int itemCount;
  // final Widget Function(BuildContext, int) itemBuilder;

  const OffersListView({
    Key? key,
    required this.medicines,
    // required this.itemCount,
    // required this.itemBuilder,
  }) : super(key: key);
  final List<MedicineEntity> medicines;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 188.h,
      child: ListView.builder(
        itemCount: medicines.length,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) => OffersListViewItem(
          index: index,
          isFavorite: false,
          onFavoritePressed: () {},
          medicineEntity: medicines[index],
        ),
      ),
    );
  }
}

// Example usage:
// OffersList(
//   itemCount: offers.length,
//   itemBuilder: (context, index) => OffersListViewItem(
//     index: index,
//     isFavorite: true,
//     onTap: () {
//       Navigator.pushReplacementNamed(context, ProductView.routeName);
//     },
//     onFavoritePressed: () {},
//   ),
// )
 // _buildOffersList() {
  //   return SizedBox(
  //     height: 168.h,
  //     child: ListView.builder(
  //       itemCount: 5, // Replace with your actual item count
  //       shrinkWrap: true,
  //       scrollDirection: Axis.horizontal,
  //       itemBuilder: (context, index) => OffersListViewItem(
  //         index: index,
  //         isFavorite: true,
  //         onTap: () {
  //           Navigator.pushReplacementNamed(context, ProductView.routeName);
  //         },
  //         onFavoritePressed:
  //             () {}, // You'll need to provide actual product data here
  //       ),
  //     ),
  //   );
  // }

//   _buildNewProductsList() {
//     return SizedBox(
//       height: 188.h,
//       child: ListView.builder(
//         itemCount: 5, // Replace with your actual item count
//         shrinkWrap: true,
//         scrollDirection: Axis.horizontal,
//         itemBuilder: (context, index) => NewProductsListViewItem(
//           index: index,
//           isFavorite: true,
//           onFavoritePressed:
//               () {}, // You'll need to provide actual product data here
//         ),
//       ),
//     );
//   }
// }
