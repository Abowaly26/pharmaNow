import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pharma_now/core/utils/color_manger.dart';
import 'package:pharma_now/features/home/presentation/views/main_view.dart';
import 'package:pharma_now/features/home/presentation/views/widgets/product_view_body.dart';

import '../../../../core/utils/app_images.dart';

class ProductView extends StatelessWidget {
  static const String routeName = "ProductView";

  const ProductView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: ColorManager.secondaryColor,
        title: Text(
          "Details",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, MainView.routeName);
          },
          icon: SvgPicture.asset(
            Assets.arrowLeft,
            width: 24,
            height: 24,
            color: ColorManager.primaryColor,
          ),
        ),
      ),
      body: ProductViewBody(
        isFavorite: true,
      ),
    );
  }
}
