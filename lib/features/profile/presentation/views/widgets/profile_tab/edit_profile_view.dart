import 'dart:developer';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pharma_now/core/helper_functions/build_error_bar.dart';
import 'package:pharma_now/core/utils/text_styles.dart';
import 'package:pharma_now/core/widgets/profile_avatar.dart';
import 'package:provider/provider.dart';
import '../../../../../../core/utils/app_images.dart';
import '../../../../../../core/utils/button_style.dart';
import '../../../../../../core/utils/color_manger.dart';
import '../../../../../../core/widgets/custom_app_bar.dart';
import '../../../../../../core/widgets/custom_text_field.dart';
import '../../../../presentation/providers/profile_provider.dart';

class EditProfile extends StatefulWidget {
  static const String routeName = "EditProfile";
  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ProfileProvider>(context, listen: false);
      if (provider.currentUser != null &&
          provider.currentUser!.name.isNotEmpty) {
        _nameController.text = provider.currentUser!.name;
      } else {
        final firebaseUser = FirebaseAuth.instance.currentUser;
        _nameController.text = firebaseUser?.displayName ??
            firebaseUser?.email?.split('@')[0] ??
            '';
      }
      log('Initialized name controller with: ${_nameController.text}',
          name: 'EditProfile');
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

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
      log('Error picking image: $e', name: 'EditProfile');
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
      log('Error removing image: $e', name: 'EditProfile');
      if (mounted) {
        showCustomBar(context, 'Failed to remove profile photo');
      }
    }
  }

  Future<void> _updateProfile() async {
    final provider = Provider.of<ProfileProvider>(context, listen: false);
    if (_nameController.text.trim().isEmpty) {
      showCustomBar(context, 'Please enter a valid name');
      return;
    }

    await provider.updateProfile(
      name: _nameController.text.trim(),
    );
    if (mounted) {
      if (provider.status == ProfileStatus.error) {
        showCustomBar(context, provider.errorMessage);
      } else {
        showCustomBar(
            type: MessageType.success, context, 'Profile updated successfully');
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileProvider>(context);
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final avatarRadius = width * 0.2;

    return Scaffold(
      backgroundColor: ColorManager.primaryColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(48.sp),
        child: PharmaAppBar(
          title: 'Edit Profile',
          isBack: true,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 0.04 * width),
            child: Column(
              children: [
                SizedBox(height: 0.03 * height),
                // Profile Avatar with edit capability
                Consumer<ProfileProvider>(
                  builder: (context, currentProviderState, child) {
                    return ProfileAvatar(
                      imageUrl:
                          currentProviderState.currentUser?.profileImageUrl,
                      userName: currentProviderState.currentUser?.name,
                      radius: avatarRadius,
                      showArc: true,
                      showEditOverlay: true,
                      isLoading: currentProviderState.isLoading,
                      onEditTap: _showImagePickerOptions,
                    );
                  },
                ),
                SizedBox(height: 0.02 * height),
                Consumer<ProfileProvider>(
                  builder: (context, providerData, _) {
                    String userName = providerData.currentUser?.name ?? '';
                    if (providerData.currentUser == null || userName.isEmpty) {
                      final firebaseUser = FirebaseAuth.instance.currentUser;
                      userName = firebaseUser?.displayName ??
                          firebaseUser?.email?.split('@')[0] ??
                          "Guest";
                    }
                    if (_nameController.text.isNotEmpty) {
                      userName = _nameController.text;
                    }
                    return Text(
                      userName.isNotEmpty ? userName : "Guest",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    );
                  },
                ),
                SizedBox(height: 0.01 * height),
                Consumer<ProfileProvider>(
                  builder: (context, providerData, _) {
                    final userEmail = providerData.currentUser?.email ?? "";
                    return Text(
                      userEmail,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    );
                  },
                ),
                SizedBox(height: 0.04 * height),
                CustomTextField(
                  controller: _nameController,
                  textInputType: TextInputType.name,
                  lable: 'Name',
                  icon: Assets.nameIcon,
                  hint: 'Enter your name',
                ),
                SizedBox(height: 0.05 * height),
                ElevatedButton(
                  style: ButtonStyles.primaryButton,
                  onPressed: provider.isLoading ||
                          provider.status == ProfileStatus.loading
                      ? null
                      : _updateProfile,
                  child: provider.isLoading ||
                          provider.status == ProfileStatus.loading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Save Changes', style: TextStyles.buttonLabel),
                ),
                SizedBox(height: 0.02 * height),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
