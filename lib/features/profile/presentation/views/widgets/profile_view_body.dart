import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pharma_now/core/utils/app_images.dart';
import 'package:pharma_now/core/utils/button_style.dart';
import 'package:pharma_now/core/widgets/profile_avatar.dart';

import 'package:pharma_now/core/utils/color_manger.dart';
import 'package:pharma_now/core/utils/text_styles.dart';
import 'package:pharma_now/features/profile/presentation/views/widgets/profile_tab/change_password_view.dart';
import 'package:pharma_now/features/profile/presentation/views/widgets/profile_tab/edit_profile_view.dart';
import 'package:provider/provider.dart';
import 'package:pharma_now/features/profile/presentation/providers/profile_provider.dart';

import '../../../../../core/helper_functions/build_error_bar.dart';
import '../../../../../core/widgets/password_field.dart';
import 'profile_tab/notification_view.dart';
import 'profile_tab/terms_of_service_view.dart';
import 'profile_tab/help_support_view.dart';

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
      onTap: onTap ?? () {},
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFFDBEAFE),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor ?? Color(0xFF3638DA),
                size: 20,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: textColor ?? Color(0xff4F5A69),
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 14, color: ColorManager.colorOfArrows),
          ],
        ),
      ),
    );
  }
}

class ProfileViewBody extends StatefulWidget {
  const ProfileViewBody({super.key});

  @override
  State<ProfileViewBody> createState() => _ProfileViewBodyState();
}

class _ProfileViewBodyState extends State<ProfileViewBody> {
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _showImagePickerOptions() async {
    final provider = Provider.of<ProfileProvider>(context, listen: false);
    final hasProfileImage = provider.currentUser?.profileImageUrl != null &&
        provider.currentUser!.profileImageUrl!.isNotEmpty;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: ColorManager.primaryColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 20.h),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                Text(
                  'Change Profile Photo',
                  style: TextStyles.settingItemTitle.copyWith(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20.h),
                _buildOptionTile(
                  icon: Icons.camera_alt_outlined,
                  title: 'Take Photo',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                _buildOptionTile(
                  icon: Icons.photo_library_outlined,
                  title: 'Choose from Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (hasProfileImage)
                  _buildOptionTile(
                    icon: Icons.delete_outline,
                    title: 'Remove Photo',
                    iconColor: Colors.red,
                    textColor: Colors.red,
                    onTap: () {
                      Navigator.pop(context);
                      _removeProfileImage();
                    },
                  ),
                SizedBox(height: 10.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: ColorManager.secondaryColor,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: (iconColor ?? ColorManager.secondaryColor).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: iconColor ?? ColorManager.secondaryColor,
          size: 24.sp,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          color: textColor ?? Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        final provider = Provider.of<ProfileProvider>(context, listen: false);
        await provider.updateProfileImage(imageFile);

        if (mounted) {
          if (provider.status == ProfileStatus.error) {
            showCustomBar(context, provider.errorMessage);
          } else {
            showCustomBar(
              context,
              'Profile photo updated successfully',
              type: MessageType.success,
            );
          }
        }
      }
    } catch (e) {
      log('Error picking image: $e', name: 'ProfileViewBody');
      if (mounted) {
        showCustomBar(context, 'Failed to pick image');
      }
    }
  }

  Future<void> _removeProfileImage() async {
    try {
      final provider = Provider.of<ProfileProvider>(context, listen: false);
      await provider.removeProfileImage();

      if (mounted) {
        if (provider.status == ProfileStatus.error) {
          showCustomBar(context, provider.errorMessage);
        } else {
          showCustomBar(
            context,
            'Profile photo removed',
            type: MessageType.success,
          );
        }
      }
    } catch (e) {
      log('Error removing image: $e', name: 'ProfileViewBody');
      if (mounted) {
        showCustomBar(context, 'Failed to remove profile photo');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final avatarRadius = width * 0.15;

    return SafeArea(
      child: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          final user = provider.currentUser;

          return SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: 0.02 * height),
                  ProfileAvatar(
                    imageUrl: user?.profileImageUrl,
                    userName: user?.name,
                    radius: avatarRadius,
                    showArc: true,
                    showEditOverlay: true,
                    isLoading: false, // Keep background stable
                    onEditTap: _showImagePickerOptions,
                  ),
                  SizedBox(height: 0.01 * height),
                  Text(
                    user?.name ?? "User Name Placeholder",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 0.01 * height),
                  Text(
                    user?.email ?? "user.email@example.com",
                    style: TextStyle(fontSize: 16, color: Color(0xff718096)),
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
                      Navigator.pushNamed(
                          context, TermsOfServiceView.routeName);
                    },
                  ),
                  SizedBox(height: 0.01 * height),
                  SettingItem(
                    icon: Icons.lock,
                    title: "Change Password",
                    onTap: () {
                      Navigator.pushNamed(
                          context, ChangePasswordView.routeName);
                    },
                  ),
                  SizedBox(height: 0.01 * height),
                  SettingItem(
                    icon: Icons.help_outlined,
                    title: "Help & Support",
                    onTap: () {
                      Navigator.pushNamed(context, HelpSupportView.routeName);
                    },
                  ),
                  SizedBox(height: 0.01 * height),
                  SettingItem(
                    icon: Icons.delete_forever,
                    title: "Delete Account",
                    onTap: () {
                      _showReAuthDialog(context,
                          Provider.of<ProfileProvider>(context, listen: false));
                    },
                  ),
                  SettingItem(
                    icon: Icons.logout,
                    title: "Log Out",
                    onTap: () {
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) {
                          bool isLoggingOut = false;
                          return StatefulBuilder(
                            builder: (context, setDialogState) {
                              return AlertDialog(
                                backgroundColor: ColorManager.primaryColor,
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20.0.w),
                                      child: Text(
                                        'Are you sure you want to log out?',
                                        style: TextStyles.skip
                                            .copyWith(color: Colors.black),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextButton(
                                        onPressed: isLoggingOut
                                            ? null
                                            : () async {
                                                setDialogState(
                                                    () => isLoggingOut = true);
                                                try {
                                                  final profileProvider =
                                                      Provider.of<
                                                              ProfileProvider>(
                                                          context,
                                                          listen: false);
                                                  await profileProvider
                                                      .logout();
                                                } catch (e) {
                                                  setDialogState(() =>
                                                      isLoggingOut = false);
                                                  if (context.mounted) {
                                                    showCustomBar(
                                                        context, e.toString());
                                                  }
                                                }
                                              },
                                        child: isLoggingOut
                                            ? SizedBox(
                                                height: 20.w,
                                                width: 20.w,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: ColorManager
                                                      .secondaryColor,
                                                ),
                                              )
                                            : Text('Logout',
                                                style: TextStyles.buttonLabel
                                                    .copyWith(
                                                        color: ColorManager
                                                            .redColorF5)),
                                      ),
                                      SizedBox(width: 28.w),
                                      ElevatedButton(
                                        style: ButtonStyles.smallButton,
                                        onPressed: isLoggingOut
                                            ? null
                                            : () {
                                                Navigator.of(context).pop();
                                              },
                                        child: Text('Cancel',
                                            style: TextStyles.buttonLabel
                                                .copyWith(
                                                    color: ColorManager
                                                        .primaryColor)),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showReAuthDialog(BuildContext context, ProfileProvider provider) {
    final TextEditingController passwordController = TextEditingController();
    final user = FirebaseAuth.instance.currentUser;

    bool isGoogleUser = user?.providerData
            .any((userInfo) => userInfo.providerId == 'google.com') ??
        false;

    bool shouldShowPassword = !isGoogleUser &&
        (user?.providerData
                .any((userInfo) => userInfo.providerId == 'password') ??
            false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool isDeleting = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: ColorManager.primaryColor,
              title:
                  Text('Delete Account', style: TextStyle(color: Colors.red)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Are you sure you want to delete your account? This action cannot be undone.',
                    style: TextStyles.skip.copyWith(color: Colors.black),
                  ),
                  if (shouldShowPassword) ...[
                    SizedBox(height: 10),
                    PasswordFiled(
                      controller: passwordController,
                      lable: 'Password',
                      icon: Assets.passwordIcon,
                      hint: 'Password',
                      textInputType: TextInputType.visiblePassword,
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed:
                      isDeleting ? null : () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: isDeleting ? Colors.grey : Colors.red),
                  onPressed: isDeleting
                      ? null
                      : () async {
                          if (shouldShowPassword &&
                              passwordController.text.isEmpty) {
                            showCustomBar(
                                context, 'Please enter your password');
                            return;
                          }

                          setDialogState(() => isDeleting = true);
                          try {
                            final passwordToSend = shouldShowPassword
                                ? passwordController.text
                                : null;

                            await provider
                                .reauthenticateAndDelete(passwordToSend);
                            // Navigation happens on success
                          } catch (e) {
                            setDialogState(() => isDeleting = false);
                            if (context.mounted) {
                              showCustomBar(context, e.toString());
                            }
                          }
                        },
                  child: isDeleting
                      ? SizedBox(
                          height: 20.h,
                          width: 20.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.redAccent,
                          ),
                        )
                      : Text('Confirm', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
