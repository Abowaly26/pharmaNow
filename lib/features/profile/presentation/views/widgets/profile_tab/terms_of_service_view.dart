import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/core/utils/color_manger.dart';
import 'package:pharma_now/core/widgets/custom_app_bar.dart';
import 'terms_of_service_content.dart';

class TermsOfServiceView extends StatelessWidget {
  static const String routeName = "TermsOfService";

  const TermsOfServiceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.primaryColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(48.sp),
        child: PharmaAppBar(
          title: 'Terms of Service',
          isBack: true,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: const TermsOfServiceContent(),
    );
  }
}
