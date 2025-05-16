import 'dart:developer';
import 'dart:io'; // Can be removed if no longer used in this file
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/core/utils/text_styles.dart';
// import 'package:image_picker/image_picker.dart'; // Removed
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
  // File? _selectedImage; // Removed
  // bool _isUploading = false; // Removed

  @override
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

  // Removed _selectImage function
  // Future<void> _selectImage() async { ... }

  // Removed _uploadProfileImage function
  // Future<void> _uploadProfileImage() async { ... }

  Future<void> _updateProfile() async {
    final provider = Provider.of<ProfileProvider>(context, listen: false);
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid name')));
      return;
    }

    await provider.updateProfile(
      name: _nameController.text.trim(),
    );
    if (mounted) {
      if (provider.status == ProfileStatus.error) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(provider.errorMessage)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')));
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
          // Ensure PharmaAppBar is defined correctly
          title: 'Edit Profile', // App bar title
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
                // Display avatar (initial letter only)
                Consumer<ProfileProvider>(
                  // Use Consumer to get the latest Provider data
                  builder: (context, currentProviderState, child) {
                    String initialLetter = '?';
                    if (currentProviderState.currentUser != null &&
                        currentProviderState.currentUser!.name.isNotEmpty) {
                      initialLetter = currentProviderState.currentUser!.name[0]
                          .toUpperCase();
                    }
                    return CircleAvatar(
                      radius: avatarRadius,
                      backgroundColor: Colors.purple, // Avatar background color
                      child: Text(
                        initialLetter,
                        style: TextStyle(
                          fontSize: avatarRadius * 0.8,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
                // Removed Stack and Positioned for camera
                SizedBox(height: 0.01 * height),
                Consumer<ProfileProvider>(
                  builder: (context, providerData, _) {
                    String userName = providerData.currentUser?.name ?? '';
                    if (providerData.currentUser == null || userName.isEmpty) {
                      final firebaseUser = FirebaseAuth.instance.currentUser;
                      userName = firebaseUser?.displayName ??
                          firebaseUser?.email?.split('@')[0] ??
                          "User";
                    }
                    if (_nameController.text.isNotEmpty) {
                      userName = _nameController.text;
                    }
                    return Text(
                      userName.isNotEmpty ? userName : "User",
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
                  // Ensure CustomTextField is defined correctly
                  controller: _nameController,
                  textInputType: TextInputType.name,
                  lable: 'Name', // Name field label
                  icon: Assets.nameIcon, // Ensure Assets.nameIcon is defined
                  hint: 'Enter your name', // Hint text for name field
                  // You can add onChanged here if you want to update the Consumer for name immediately
                  // onChanged: (value) {
                  //   // setState(() {}); // Simple way to rebuild the Consumer for name
                  // }
                ),
                SizedBox(height: 0.05 * height),
                ElevatedButton(
                  style: ButtonStyles
                      .primaryButton, // Ensure ButtonStyles.primaryButton is defined
                  onPressed: provider.isLoading ||
                          provider.status == ProfileStatus.loading
                      ? null
                      : _updateProfile, // Disable button during loading
                  child: provider.isLoading ||
                          provider.status == ProfileStatus.loading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Save Changes',
                          style: TextStyles.buttonLabel), // Save button text
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
