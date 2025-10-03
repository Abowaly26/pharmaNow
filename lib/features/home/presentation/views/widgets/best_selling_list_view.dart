  // import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:pharma_now/core/enitites/medicine_entity.dart';

// import 'best_selling_list_view_item.dart';

// class BestSellingListView extends StatelessWidget {
//   // final int itemCount;
//   // final Widget Function(BuildContext, int) itemBuilder;

//   final List<MedicineEntity> medicines;

//   const BestSellingListView({
//     Key? key,
//     required this.medicines,
//     // required this.itemCount,
//     // required this.itemBuilder,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 188.h,
//       child: ListView.builder(
//           itemCount: medicines.length,
//           shrinkWrap: true,
//           scrollDirection: Axis.horizontal,
//           itemBuilder: (context, index) => BestSellingListViewItem(
//                 medicineEntity: medicines[index],
//                 index: index,
//                 isFavorite: false,
//                 onFavoritePressed: () {},
//               )),
//     );
//   }
// }
