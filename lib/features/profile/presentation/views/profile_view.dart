import 'package:flutter/material.dart';
import 'package:pharma_now/features/profile/presentation/views/widgets/profile_view_body.dart';

import '../../../../core/utils/color_manger.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});
  static const routeName = 'ProfileView';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.primaryColor,
      body: ProfileViewBody(),
    );
  }
}
