import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/core/utils/color_manger.dart';
import 'package:pharma_now/core/utils/text_styles.dart';
import 'package:pharma_now/core/widgets/custom_app_bar.dart';

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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Introduction Section
            _buildSectionTitle('Welcome to PharmaNow'),
            SizedBox(height: 12.h),
            _buildSectionContent(
              'By using PharmaNow, you agree to these Terms of Service. Please read them carefully before using our services.',
            ),
            SizedBox(height: 24.h),

            // Section 1
            _buildSectionTitle('1. Acceptance of Terms'),
            SizedBox(height: 12.h),
            _buildSectionContent(
              'By accessing and using PharmaNow, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to abide by the above, please do not use this service.',
            ),
            SizedBox(height: 20.h),

            // Section 2
            _buildSectionTitle('2. Use of Service'),
            SizedBox(height: 12.h),
            _buildSectionContent(
              'PharmaNow provides a platform for users to search, compare, and purchase pharmaceutical products from registered pharmacies. You agree to use the service only for lawful purposes and in accordance with these Terms.',
            ),
            SizedBox(height: 20.h),

            // Section 3
            _buildSectionTitle('3. User Account'),
            SizedBox(height: 12.h),
            _buildBulletPoint(
              'You are responsible for maintaining the confidentiality of your account credentials.',
            ),
            SizedBox(height: 8.h),
            _buildBulletPoint(
              'You must provide accurate and complete information when creating an account.',
            ),
            SizedBox(height: 8.h),
            _buildBulletPoint(
              'You are responsible for all activities that occur under your account.',
            ),
            SizedBox(height: 20.h),

            // Section 4
            _buildSectionTitle('4. Product Information'),
            SizedBox(height: 12.h),
            _buildSectionContent(
              'While we strive to provide accurate product information, we do not warrant that product descriptions, pricing, or other content is accurate, complete, or error-free. Always consult with a healthcare professional before using any medication.',
            ),
            SizedBox(height: 20.h),

            // Section 5
            _buildSectionTitle('5. Orders and Payments'),
            SizedBox(height: 12.h),
            _buildBulletPoint(
              'All orders are subject to availability and confirmation of the order price.',
            ),
            SizedBox(height: 8.h),
            _buildBulletPoint(
              'Payment must be made through our approved payment methods.',
            ),
            SizedBox(height: 8.h),
            _buildBulletPoint(
              'Prices are subject to change without notice.',
            ),
            SizedBox(height: 20.h),

            // Section 6
            _buildSectionTitle('6. Privacy Policy'),
            SizedBox(height: 12.h),
            _buildSectionContent(
              'Your privacy is important to us. Our Privacy Policy explains how we collect, use, and protect your personal information. By using PharmaNow, you consent to our data practices as described in our Privacy Policy.',
            ),
            SizedBox(height: 20.h),

            // Section 7
            _buildSectionTitle('7. Intellectual Property'),
            SizedBox(height: 12.h),
            _buildSectionContent(
              'All content on PharmaNow, including text, graphics, logos, and software, is the property of PharmaNow and is protected by copyright and intellectual property laws.',
            ),
            SizedBox(height: 20.h),

            // Section 8
            _buildSectionTitle('8. Limitation of Liability'),
            SizedBox(height: 12.h),
            _buildSectionContent(
              'PharmaNow shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use of or inability to use the service.',
            ),
            SizedBox(height: 20.h),

            // Section 9
            _buildSectionTitle('9. Modifications to Terms'),
            SizedBox(height: 12.h),
            _buildSectionContent(
              'We reserve the right to modify these Terms of Service at any time. Changes will be effective immediately upon posting. Your continued use of PharmaNow after changes are posted constitutes your acceptance of the modified terms.',
            ),
            SizedBox(height: 20.h),

            // Section 10
            _buildSectionTitle('10. Contact Us'),
            SizedBox(height: 12.h),
            _buildSectionContent(
              'If you have any questions about these Terms of Service, please contact us through the Help & Support section.',
            ),
            SizedBox(height: 20.h),

            // Last Updated
            Center(
              child: Text(
                'Last Updated: December 2025',
                style: TextStyles.listView_product_subInf.copyWith(
                  fontSize: 11.sp,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyles.sectionTitle.copyWith(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: ColorManager.blackColor,
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Text(
      content,
      style: TextStyles.description.copyWith(
        fontSize: 13.sp,
        color: ColorManager.greyColor,
        height: 1.5,
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 6.h, right: 8.w),
          child: Container(
            width: 6.w,
            height: 6.h,
            decoration: BoxDecoration(
              color: ColorManager.secondaryColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyles.description.copyWith(
              fontSize: 13.sp,
              color: ColorManager.greyColor,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
