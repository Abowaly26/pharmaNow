import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/features/offers/presentation/views/widgets/offers_view_body.dart';

import '../../../../core/utils/color_manger.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../home/presentation/views/main_view.dart';

class OffersView extends StatelessWidget {
  const OffersView({super.key});
  static const routeName = 'OffersView';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.primaryColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(48.sp),
        child: PharmaAppBar(
            title: 'Offers',
            isBack: true,
            onPressed: () {
              Navigator.pushReplacementNamed(context, MainView.routeName);
            }),
      ),
      body: OffersViewBody(),
    );
  }
}
