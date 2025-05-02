import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/features/home/presentation/views/widgets/category_widget.dart';
import 'package:pharma_now/features/home/presentation/views/widgets/offers_list_view_item.dart';
import 'package:pharma_now/features/home/presentation/views/widgets/section_widget.dart';

import '../../../../../core/cubits/medicine_cubit/medicine_cubit.dart';
import '../../../../../core/utils/app_images.dart';
import '../../../../../core/utils/button_style.dart';
import '../../../../../core/utils/color_manger.dart';
import '../../../../../core/utils/text_style.dart';
import '../../../../new products/presentation/views/new_products_view.dart';
import '../../../../offers/presentation/views/offers_view.dart';
import '../../../../shopping by category/presentation/views/categories_view.dart';
import '../product_view.dart';
import 'new _products_list_view_item.dart';

class HomeViewBody extends StatefulWidget {
  const HomeViewBody({super.key});

  @override
  State<HomeViewBody> createState() => _HomeViewBodyState();
}

class _HomeViewBodyState extends State<HomeViewBody> {
  @override
  void initState() {
    context.read<MedicineCubit>().getMedicines();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.w),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                    width: double.infinity,
                    child: Image.asset(
                      Assets.home_bannner,
                      fit: BoxFit.fill,
                    )),
                Positioned(
                  top: 30,
                  left: 42,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Discount ',
                        style: TextStyles.bold24Black,
                      ),
                      Text(
                        '50%',
                        style: TextStyles.bold24Black
                            .copyWith(color: ColorManager.redColorF5),
                      ),
                      SizedBox(),
                      ElevatedButton(
                          style: ButtonStyles.smallButton,
                          onPressed: () {},
                          child: Text(
                            'Buy Now',
                            style: TextStyles.buttonLabel,
                          ))
                    ],
                  ),
                )
              ],
            ),
            SectionWidget(
              sectionTitle: 'Categories',
              onTap: () {
                Navigator.pushReplacementNamed(
                    context, CategoriesView.routeName);
              },
            ),
            _buildCategoriesList(),
            SectionWidget(
              sectionTitle: 'Offers',
              onTap: () {
                Navigator.pushReplacementNamed(context, OffersView.routeName);
              },
            ),
            _buildOffersList(),
            SectionWidget(
              sectionTitle: 'New Products',
              onTap: () {
                Navigator.pushReplacementNamed(
                    context, NewProductView.routeName);
              },
            ),
            _buildNewProductsList(),
            SizedBox(
              height: 48,
            )
          ],
        ),
      ),
    );
  }

  _buildCategoriesList() {
    return SizedBox(
      height: 110.h,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: 5, // Replace with your actual item count
        itemBuilder: (context, index) => CategoryWidget(
            // Replace with your actual category data
            // You'll need to provide actual category data here
            ),
      ),
    );
  }

  _buildOffersList() {
    return SizedBox(
      height: 168.h,
      child: ListView.builder(
        itemCount: 5, // Replace with your actual item count
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) => OffersListViewItem(
          index: index,
          isFavorite: true,
          onTap: () {
            Navigator.pushReplacementNamed(context, ProductView.routeName);
          },
          onFavoritePressed:
              () {}, // You'll need to provide actual product data here
        ),
      ),
    );
  }

  _buildNewProductsList() {
    return SizedBox(
      height: 188.h,
      child: ListView.builder(
        itemCount: 5, // Replace with your actual item count
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) => NewProductsListViewItem(
          index: index,
          isFavorite: true,
          onFavoritePressed:
              () {}, // You'll need to provide actual product data here
        ),
      ),
    );
  }
}
