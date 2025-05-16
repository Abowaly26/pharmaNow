import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/core/utils/button_style.dart';

import 'package:pharma_now/core/utils/color_manger.dart';
import 'package:pharma_now/core/utils/text_styles.dart';
import 'package:pharma_now/features/profile/presentation/views/widgets/profile_tab/change_password_view.dart';
import 'package:pharma_now/features/profile/presentation/views/widgets/profile_tab/edit_profile_view.dart';
import 'package:provider/provider.dart';
import 'package:pharma_now/features/profile/presentation/providers/profile_provider.dart';

// ArcPainter and SettingItem remain the same
class ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.blue.withOpacity(0.3) // Example arc color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawArc(
      Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: size.width / 2),
      0,
      3.14 * 2,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class SettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? textColor;

  const SettingItem({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {}, // Add required parameter
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFFDBEAFE), // Icon background color
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor ?? Color(0xFF3638DA), // Icon color
                size: 20,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: textColor ?? Color(0xff4F5A69), // Text color
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 14, color: ColorManager.colorOfArrows), // Arrow color
          ],
        ),
      ),
    );
  }
}

class ProfileViewBody extends StatelessWidget {
  const ProfileViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final avatarRadius = width * 0.15;

    return SafeArea(
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 0.03 * height),
              Consumer<ProfileProvider>(
                builder: (context, provider, child) {
                  Widget avatarContent;
                  if (provider.status == ProfileStatus.loading &&
                      provider.currentUser == null) {
                    avatarContent = CircleAvatar(
                      radius: avatarRadius,
                      backgroundColor: Colors.grey[300],
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    );
                  } else if (provider.currentUser != null &&
                      provider.currentUser!.name.isNotEmpty) {
                    avatarContent = CircleAvatar(
                      radius: avatarRadius,
                      backgroundColor: Colors.purple,
                      child: Text(
                        provider.currentUser!.name[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: avatarRadius * 0.8,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    );
                  } else {
                    final firebaseUser = FirebaseAuth.instance.currentUser;
                    final fallbackName = firebaseUser?.displayName ??
                        firebaseUser?.email?.split('@')[0] ??
                        '?';
                    avatarContent = CircleAvatar(
                      radius: avatarRadius,
                      backgroundColor: Colors.deepPurple,
                      child: Text(
                        fallbackName.isNotEmpty
                            ? fallbackName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: avatarRadius * 0.8,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    );
                  }
                  return avatarContent;
                },
              ),
              SizedBox(height: 0.01 * height),
              Consumer<ProfileProvider>(
                builder: (context, provider, child) {
                  if (provider.status == ProfileStatus.loading &&
                      provider.currentUser == null) {
                    return Text(
                      "Loading...",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    );
                  }
                  final firebaseUser = FirebaseAuth.instance.currentUser;
                  final userName = provider.currentUser?.name ??
                      firebaseUser?.displayName ??
                      firebaseUser?.email?.split('@')[0] ??
                      "User";
                  return Text(
                    userName.isNotEmpty ? userName : "User",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  );
                },
              ),
              SizedBox(height: 0.01 * height),
              Consumer<ProfileProvider>(
                builder: (context, provider, child) {
                  if (provider.status == ProfileStatus.loading &&
                      provider.currentUser == null) {
                    return Text(
                      "Loading email...", // Loading state text for email
                      style: TextStyle(fontSize: 16, color: Color(0xff718096)),
                    );
                  }
                  // Use email from Provider, or empty value if not available
                  final userEmail = provider.currentUser?.email ?? "";
                  return Text(
                    userEmail,
                    style: TextStyle(fontSize: 16, color: Color(0xff718096)),
                  );
                },
              ),
              SizedBox(height: 0.04 * height),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 0.056 * width),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Account Settings', // Account settings title
                    style: TextStyles.settingItemTitle
                        .copyWith(color: Color(0xFF4F5159)),
                  ),
                ),
              ),
              SettingItem(
                icon: Icons.person,
                title: "Edit Profile", // Edit profile
                onTap: () {
                  Navigator.pushNamed(context, EditProfile.routeName);
                },
              ),
              SettingItem(
                icon: Icons.notifications,
                title: "Notifications", // Notifications
                onTap: () {
                  // Navigator.pushNamed(context, Notifications.routeName); // Ensure this route exists
                },
              ),
              SizedBox(height: 0.01 * height),
              SettingItem(
                icon: Icons.security,
                title: "Terms of Service", // Terms of service
                onTap: () {
                  // ... (Existing code for displaying terms of service)
                },
              ),
              SizedBox(height: 0.01 * height),
              SettingItem(
                icon: Icons.lock,
                title: "Change Password", // Change password
                onTap: () {
                  Navigator.pushNamed(context, ChangePasswordView.routeName);
                  // Navigator.pushNamed(context, ChangePasswordView.routeName); // Ensure this route exists
                },
              ),
              SizedBox(height: 0.01 * height),
              SettingItem(
                icon: Icons.help_outlined,
                title: "Help & Support", // Help & support
                onTap: () {
                  // ... (Existing code for displaying help & support)
                },
              ),
              SizedBox(height: 0.01 * height),
              SettingItem(
                icon: Icons.logout,
                title: "Log Out",
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: ColorManager.primaryColor,
                      content: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0.w),
                        child: Text(
                          'Are you sure you want to log out?',
                          style: TextStyles.skip.copyWith(color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      actions: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0.w),
                          child: TextButton(
                            onPressed: () async {
                              try {
                                // Show loading dialog
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );

                                // Perform logout using the profile provider
                                final profileProvider =
                                    Provider.of<ProfileProvider>(context,
                                        listen: false);
                                await profileProvider.logout();

                                // Navigate to login screen
                                if (context.mounted) {
                                  Navigator.of(context)
                                      .pop(); // Close loading dialog
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                    'loginView',
                                    (route) => false,
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  Navigator.of(context)
                                      .pop(); // Close loading dialog on error
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Logout failed: ${e.toString()}',
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  log('Logout error: $e',
                                      name: 'ProfileViewBody');
                                }
                              }
                            },
                            child: Text('Logout',
                                style: TextStyles.buttonLabel
                                    .copyWith(color: ColorManager.redColorF5)),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 10.0.w),
                          child: ElevatedButton(
                            style: ButtonStyles.smallButton,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Cancel',
                                style: TextStyles.buttonLabel.copyWith(
                                    color: ColorManager.primaryColor)),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
