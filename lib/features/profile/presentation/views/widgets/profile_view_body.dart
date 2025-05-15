import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/core/utils/button_style.dart';
import 'package:pharma_now/core/utils/color_manger.dart';
import 'package:pharma_now/core/utils/text_styles.dart';
import 'package:pharma_now/features/home/presentation/views/widgets/home_appbar.dart';
import 'package:pharma_now/features/profile/presentation/views/widgets/profile_tab/CustomRowWidget.dart';
import 'package:pharma_now/features/profile/presentation/views/widgets/profile_tab/edit_profile_view.dart';
import 'package:pharma_now/features/profile/presentation/views/widgets/profile_tab/notification_view.dart';
import 'package:pharma_now/features/profile/presentation/views/widgets/profile_tab/change_password_view.dart';
import 'package:pharma_now/core/services/shard_preferences_singlton.dart';
import 'package:pharma_now/constants.dart';
import 'package:provider/provider.dart';
import 'package:pharma_now/features/profile/presentation/providers/profile_provider.dart';
import '../../../../../core/helper_functions/get_user.dart';

class ProfileViewBody extends StatelessWidget {
  const ProfileViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final avatarRadius = width * 0.15;
    final outerCircleSize = avatarRadius * 2.2;

    return SafeArea(
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 0.03 * height),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: outerCircleSize,
                    height: outerCircleSize,
                    child: CustomPaint(painter: ArcPainter()),
                  ),
                  Consumer<ProfileProvider>(
                    builder: (context, provider, child) {
                      return CircleAvatar(
                        radius: avatarRadius,
                        backgroundImage: provider.profileImageUrl != null
                            ? NetworkImage(provider.profileImageUrl!)
                            : null,
                        backgroundColor: Colors.purple,
                        child: provider.profileImageUrl == null
                            ? Text(
                                // Check if the username exists and is not empty before accessing the first letter
                                provider.currentUser != null &&
                                        provider.currentUser!.name.isNotEmpty
                                    ? provider.currentUser!.name[0]
                                        .toUpperCase()
                                    : getUser().name.isNotEmpty
                                        ? getUser().name[0].toUpperCase()
                                        : '?',
                                style: TextStyle(
                                  fontSize: avatarRadius * 0.8,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      );
                    },
                  ),
                  Positioned(
                    left: width * 0.25,
                    right: width * 0.19,
                    bottom: width * 0.01,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 20,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 0.01 * height),
              Consumer<ProfileProvider>(
                builder: (context, provider, child) {
                  final userName = provider.currentUser != null &&
                          provider.currentUser!.name.isNotEmpty
                      ? provider.currentUser!.name
                      : getUser().name;
                  return Text(
                    userName,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  );
                },
              ),
              SizedBox(height: 0.01 * height),
              Consumer<ProfileProvider>(
                builder: (context, provider, child) {
                  final userEmail = provider.currentUser != null &&
                          provider.currentUser!.email.isNotEmpty
                      ? provider.currentUser!.email
                      : getUser().email;
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
                    'Account Settings',
                    style: TextStyles.settingItemTitle
                        .copyWith(color: Color(0xFF4F5159)),
                  ),
                ),
              ),
              SettingItem(
                icon: Icons.person,
                title: "Edit Profile",
                onTap: () {
                  Navigator.pushNamed(context, EditProfile.routeName);
                },
              ),
              SizedBox(height: 0.01 * height),
              SettingItem(
                icon: Icons.notifications,
                title: "Notifications",
                onTap: () {
                  Navigator.pushNamed(context, Notifications.routeName);
                },
              ),
              SizedBox(height: 0.01 * height),
              SettingItem(
                icon: Icons.security,
                title: "Terms of Service",
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Terms of Service'),
                      content: const Text(
                          'This text contains the terms of use and privacy policy of the application. Please read it carefully before using the application.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: 0.01 * height),
              SettingItem(
                icon: Icons.lock,
                title: "Change Password",
                onTap: () {
                  Navigator.pushNamed(context, ChangePasswordView.routeName);
                },
              ),
              SizedBox(height: 0.01 * height),
              SettingItem(
                icon: Icons.help_outlined,
                title: "Help and Support",
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Help and Support'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('For help or support, please contact us:'),
                          const SizedBox(height: 10),
                          const Text('Email: support@pharmanow.com'),
                          const SizedBox(height: 5),
                          const Text('Phone: 01xxxxxxxx'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: 0.01 * height),
              SettingItem(
                icon: Icons.logout,
                title: "Logout",
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: ColorManager.primaryColor,
                      // title: Center(child: Text('Log Out')),
                      content: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0.h),
                        child: Text(
                          'Are you sure you want to logout?',
                          style: TextStyles.skip.copyWith(color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      actions: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0.h),
                          child: ElevatedButton(
                            style: ButtonStyles.smallButton,
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cancel',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 20.0.h),
                          child: TextButton(
                            onPressed: () async {
                              Navigator.pop(context); // Close dialog
                              try {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => AlertDialog(
                                    content: Row(
                                      children: [
                                        CircularProgressIndicator(),
                                        SizedBox(width: 20),
                                        Text('Logging out...'),
                                      ],
                                    ),
                                  ),
                                );

                                await FirebaseAuth.instance.signOut();
                                await prefs.remove(kUserData);

                                Navigator.of(context).pop();
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  'loginView',
                                  (route) => false,
                                );
                              } catch (e) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Failed to log out: ${e.toString()}')),
                                );
                              }
                            },
                            child: Text('Log Out',
                                style: TextStyle(color: Colors.red)),
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
