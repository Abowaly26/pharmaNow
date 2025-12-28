import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pharma_now/core/utils/app_images.dart';
import 'package:pharma_now/core/utils/color_manger.dart';
import 'package:pharma_now/core/utils/text_styles.dart';
import 'package:pharma_now/core/widgets/custom_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

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
              subtitle: 'waly20691@gmail.com',
              onTap: () => _launchEmail('waly20691@gmail.com'),
            ),
            SizedBox(height: 12.h),

            _buildContactCard(
              icon: Icons.phone_outlined,
              title: 'Phone Support',
              subtitle: '+20 10 24941746',
              onTap: () => _launchPhone('+201024941746'),
            ),
            SizedBox(height: 12.h),

            _buildContactCard(
              iconPath: Assets.whatsappIcon,
              title: 'WhatsApp',
              subtitle: 'Chat with us on WhatsApp',
              onTap: () => _launchWhatsApp('+201024941746'),
            ),
            SizedBox(height: 12.h),

            _buildContactCard(
              iconPath: Assets.facebookIcon,
              title: 'Facebook',
              subtitle: 'Follow us on Facebook',
              onTap: () => _launchFacebook(
                  'https://www.facebook.com/profile.php?id=100072882292717&locale=ar_AR'),
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
    IconData? icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    String? iconPath,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: ColorManager.buttom_info,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: ColorManager.colorLines.withOpacity(0.5),
          width: 1.w,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: (iconColor ?? ColorManager.secondaryColor)
                        .withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: iconPath != null
                      ? SvgPicture.asset(iconPath, width: 26.sp, height: 26.sp)
                      : Icon(
                          icon,
                          color: iconColor ?? ColorManager.secondaryColor,
                          size: 26.sp,
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
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: TextStyles.description.copyWith(
                          fontSize: 12.sp,
                          color: ColorManager.greyColor.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14.sp,
                  color: ColorManager.colorOfArrows.withOpacity(0.5),
                ),
              ],
            ),
          ),
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
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Pharma Now Support Request',
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      await Clipboard.setData(ClipboardData(text: email));
    }
  }

  void _launchPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      await Clipboard.setData(ClipboardData(text: phone));
    }
  }

  void _launchWhatsApp(String phone) async {
    final Uri whatsappUri = Uri.parse("https://wa.me/$phone");
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    }
  }

  void _launchFacebook(String url) async {
    final Uri fbUri = Uri.parse(url);
    if (await canLaunchUrl(fbUri)) {
      await launchUrl(fbUri, mode: LaunchMode.externalApplication);
    }
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
