import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/features/home/presentation/views/widgets/category_widget.dart';

class CategoriesListView extends StatelessWidget {
  // You can add parameters here to make the widget more customizable
  // final int itemCount;
  // final Widget Function(BuildContext, int) itemBuilder;

  const CategoriesListView({
    Key? key,
    // required this.itemCount,
    // required this.itemBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110.h,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: 8,
        itemBuilder: (context, index) => CategoryWidget(),
      ),
    );
  }
}

// Example usage:
// CategoriesList(
//   itemCount: categories.length,
//   itemBuilder: (context, index) => CategoryWidget(
//     category: categories[index],
//   ),
// )
