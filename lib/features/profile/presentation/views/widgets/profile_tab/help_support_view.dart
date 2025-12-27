import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/core/utils/color_manger.dart';
import 'package:pharma_now/core/utils/text_styles.dart';
import 'package:pharma_now/core/widgets/custom_app_bar.dart';
import 'package:flutter/services.dart';

class HelpSupportView extends StatelessWidget {
  static const String routeName = "HelpSupport";

  const HelpSupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.primaryColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(48.sp),
        child: PharmaAppBar(
          title: 'Help & Support',
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
            // Contact Section
            _buildSectionTitle('Contact Us'),
            SizedBox(height: 16.h),

            _buildContactCard(
              icon: Icons.email_outlined,
              title: 'Email Support',
              subtitle: 'support@pharmanow.com',
              onTap: () => _launchEmail('support@pharmanow.com'),
            ),
            SizedBox(height: 12.h),

            _buildContactCard(
              icon: Icons.phone_outlined,
              title: 'Phone Support',
              subtitle: '+20 123 456 7890',
              onTap: () => _launchPhone('+201234567890'),
            ),
            SizedBox(height: 12.h),

            _buildContactCard(
              icon: Icons.chat_bubble_outline,
              title: 'Live Chat',
              subtitle: 'Available 24/7',
              onTap: () {
                // Navigate to chat or show coming soon
                _showComingSoonDialog(context);
              },
            ),

            SizedBox(height: 32.h),

            // FAQ Section
            _buildSectionTitle('Frequently Asked Questions'),
            SizedBox(height: 16.h),

            _buildFAQItem(
              question: 'How do I place an order?',
              answer:
                  'Browse our catalog, add items to your cart, and proceed to checkout. You can pay using various payment methods including credit cards and cash on delivery.',
            ),
            SizedBox(height: 12.h),

            _buildFAQItem(
              question: 'What are the delivery options?',
              answer:
                  'We offer standard delivery (2-3 business days) and express delivery (same day in select areas). Delivery fees vary based on your location.',
            ),
            SizedBox(height: 12.h),

            _buildFAQItem(
              question: 'Can I return a product?',
              answer:
                  'Due to health and safety regulations, we cannot accept returns on pharmaceutical products. However, if you receive a damaged or incorrect item, please contact us immediately.',
            ),
            SizedBox(height: 12.h),

            _buildFAQItem(
              question: 'How do I track my order?',
              answer:
                  'Once your order is confirmed, you will receive a tracking number via email and SMS. You can also track your order in the Orders section of the app.',
            ),
            SizedBox(height: 12.h),

            _buildFAQItem(
              question: 'Is my payment information secure?',
              answer:
                  'Yes, we use industry-standard encryption to protect your payment information. We do not store your credit card details on our servers.',
            ),
            SizedBox(height: 12.h),

            _buildFAQItem(
              question: 'Do I need a prescription?',
              answer:
                  'Some medications require a valid prescription. You can upload your prescription during checkout, or our pharmacist will contact you if needed.',
            ),

            SizedBox(height: 32.h),

            // Quick Links Section
            _buildSectionTitle('Quick Links'),
            SizedBox(height: 16.h),

            _buildQuickLinkCard(
              icon: Icons.local_shipping_outlined,
              title: 'Shipping Policy',
              onTap: () => _showInfoDialog(
                context,
                'Shipping Policy',
                'We deliver to most areas within Egypt. Standard delivery takes 2-3 business days, while express delivery is available in select areas for same-day delivery. Shipping fees are calculated based on your location and order value.',
              ),
            ),
            SizedBox(height: 12.h),

            _buildQuickLinkCard(
              icon: Icons.assignment_return_outlined,
              title: 'Return Policy',
              onTap: () => _showInfoDialog(
                context,
                'Return Policy',
                'Due to the nature of pharmaceutical products, we cannot accept returns. However, if you receive a damaged, defective, or incorrect item, please contact us within 24 hours of delivery for a replacement or refund.',
              ),
            ),
            SizedBox(height: 12.h),

            _buildQuickLinkCard(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () => _showInfoDialog(
                context,
                'Privacy Policy',
                'We are committed to protecting your privacy. We collect and use your personal information only to process your orders and improve our services. We do not share your information with third parties without your consent.',
              ),
            ),

            SizedBox(height: 32.h),

            // Need More Help Section
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.support_agent,
                    size: 64.sp,
                    color: ColorManager.secondaryColor.withOpacity(0.7),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Still need help?',
                    style: TextStyles.sectionTitle.copyWith(
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Our support team is here to assist you',
                    style: TextStyles.description.copyWith(
                      fontSize: 13.sp,
                      color: ColorManager.greyColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
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

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: ColorManager.buttom_info,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: ColorManager.colorLines,
            width: 1.w,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Color(0xFFDBEAFE),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: ColorManager.secondaryColor,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyles.sectionTitle.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyles.description.copyWith(
                      fontSize: 12.sp,
                      color: ColorManager.greyColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: ColorManager.colorOfArrows,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem({
    required String question,
    required String answer,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: ColorManager.buttom_info,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: ColorManager.colorLines,
          width: 1.w,
        ),
      ),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          childrenPadding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            bottom: 16.h,
          ),
          title: Text(
            question,
            style: TextStyles.sectionTitle.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          iconColor: ColorManager.secondaryColor,
          collapsedIconColor: ColorManager.greyColor,
          children: [
            Text(
              answer,
              style: TextStyles.description.copyWith(
                fontSize: 13.sp,
                color: ColorManager.greyColor,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickLinkCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: ColorManager.buttom_info,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: ColorManager.colorLines,
            width: 1.w,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: ColorManager.secondaryColor,
              size: 24.sp,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyles.sectionTitle.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: ColorManager.colorOfArrows,
            ),
          ],
        ),
      ),
    );
  }

  void _launchEmail(String email) async {
    await Clipboard.setData(ClipboardData(text: email));
    // Show a snackbar or dialog to inform user
    _showCopiedDialog('Email copied to clipboard: $email');
  }

  void _launchPhone(String phone) async {
    await Clipboard.setData(ClipboardData(text: phone));
    _showCopiedDialog('Phone number copied to clipboard: $phone');
  }

  void _showCopiedDialog(String message) {
    // This would need a BuildContext, so we'll handle it differently
    // For now, we'll just copy to clipboard
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColorManager.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Coming Soon',
          style: TextStyles.sectionTitle,
        ),
        content: Text(
          'Live chat feature will be available soon!',
          style: TextStyles.description.copyWith(
            color: ColorManager.greyColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyles.buttonLabel.copyWith(
                color: ColorManager.secondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColorManager.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          title,
          style: TextStyles.sectionTitle,
        ),
        content: SingleChildScrollView(
          child: Text(
            content,
            style: TextStyles.description.copyWith(
              color: ColorManager.greyColor,
              height: 1.5,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyles.buttonLabel.copyWith(
                color: ColorManager.secondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
