import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/features/home/presentation/views/main_view.dart';
import 'package:pharma_now/features/new%20products/presentation/views/widgets/new%20products_view_body.dart';

import '../../../../core/utils/color_manger.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class NewProductView extends StatelessWidget {
  const NewProductView({super.key});
  static const routeName = 'NewProductView';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.primaryColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(48.sp),
        child: PharmaAppBar(
          title: 'New Products',
          isBack: true,
          onPressed: () {
            Navigator.pushReplacementNamed(context, MainView.routeName);
          },
        ),
      ),
      body: NewProductViewBody(),
    );
  }
}
