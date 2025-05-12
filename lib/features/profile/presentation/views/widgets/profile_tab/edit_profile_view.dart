import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/core/utils/text_style.dart';

import '../../../../../../core/helper_functions/get_user.dart';
import '../../../../../../core/utils/app_images.dart';
import '../../../../../../core/utils/button_style.dart';
import '../../../../../../core/utils/color_manger.dart';
import '../../../../../../core/widgets/custom_app_bar.dart';
import '../../../../../../core/widgets/custom_text_field.dart';
import '../../../../../home/presentation/views/main_view.dart';
import '../../profile_view.dart';
import '../profile_view_body.dart';
import 'CustomButtom.dart';
import 'CustomTextField.dart';

class EditProfile extends StatelessWidget {
  static const String routeName = "EditProfile";

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final avatarRadius = width * 0.2;
    final outerCircleSize = avatarRadius * 2.2;
    return Scaffold(
      backgroundColor: ColorManager.primaryColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(48.sp),
        child: PharmaAppBar(
          title: 'Edit Profile',
          isBack: true,
          onPressed: () {
            Navigator.pop(
              context,
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 0.04 * width),
            child: Column(
              children: [
                SizedBox(height: 0.03 * height),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: outerCircleSize,
                      height: outerCircleSize,
                      child: CustomPaint(
                        painter: ArcPainter(),
                      ),
                    ),
                    CircleAvatar(
                      radius: avatarRadius,
                      backgroundImage: Image.asset(
                        Assets.profile,
                      ).image,
                    ),
                    Positioned(
                      left: width * 0.32,
                      right: width * 0.12,
                      bottom: width * 0.01,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 30,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.01 * height),
                Text(
                  '${getUser().name}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 0.01 * height),
                Text(
                  '${getUser().email}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 0.01 * height),
                CustomTextField(
                    textInputType: TextInputType.name,
                    lable: 'Name',
                    icon: Assets.nameIcon,
                    hint: 'Enter your name'),
                SizedBox(
                  height: 16,
                ),
                CustomTextField(
                    textInputType: TextInputType.emailAddress,
                    lable: 'Email',
                    icon: Assets.emailIcon,
                    hint: 'Enter your email'),
                SizedBox(height: 0.2 * height),
                ElevatedButton(
                  style: ButtonStyles.primaryButton,
                  onPressed: () {
                    Navigator.pop(
                      context,
                    );
                  },
                  child: Text(
                    'Save Change',
                    style: TextStyles.buttonLabel,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
