import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/features/favorites/presentation/views/widgets/favorites_view_body.dart';

import '../../../../core/utils/color_manger.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class FavoriteView extends StatelessWidget {
  const FavoriteView({super.key});
  static const routeName = 'FavoriteView';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.primaryColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(48.sp),
        child: PharmaAppBar(title: 'My Favorite'),
      ),
      body: const FavoriteViewBody(),
    );
  }
}
