import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pharma_now/core/utils/text_styles.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/helper_functions/get_user.dart';
import '../../../../../../core/utils/app_images.dart';
import '../../../../../../core/utils/button_style.dart';
import '../../../../../../core/utils/color_manger.dart';
import '../../../../../../core/widgets/custom_app_bar.dart';
import '../../../../../../core/widgets/custom_text_field.dart';
import '../../../../../home/presentation/views/widgets/home_appbar.dart';
import '../../../../presentation/providers/profile_provider.dart';
import '../profile_view_body.dart';
import 'change_password_view.dart';

class EditProfile extends StatefulWidget {
  static const String routeName = "EditProfile";

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController _nameController = TextEditingController();
  File? _selectedImage;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    // Use username from Provider if available, otherwise from getUser()
    Future.microtask(() {
      final provider = Provider.of<ProfileProvider>(context, listen: false);
      if (provider.currentUser != null &&
          provider.currentUser!.name.isNotEmpty) {
        setState(() {
          _nameController.text = provider.currentUser!.name;
        });
      } else {
        _nameController.text = getUser().name;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });

      // Upload image immediately
      _uploadProfileImage();
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final provider = Provider.of<ProfileProvider>(context, listen: false);
      await provider.updateProfileImage(_selectedImage!);

      if (provider.status == ProfileStatus.error) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(provider.errorMessage)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Profile image updated successfully')));
      }
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    final provider = Provider.of<ProfileProvider>(context, listen: false);

    await provider.updateProfile(
      name: _nameController.text.trim(),
    );

    if (provider.status == ProfileStatus.error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(provider.errorMessage)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileProvider>(context);
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
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: outerCircleSize,
                      height: outerCircleSize,
                      child: CustomPaint(painter: ArcPainter()),
                    ),
                    _isUploading
                        ? CircularProgressIndicator()
                        : Builder(builder: (context) {
                            // Check if there is a selected image or profile image
                            bool hasImage = _selectedImage != null ||
                                provider.profileImageUrl != null;
                            if (hasImage) {
                              // If there is an image, display it
                              return CircleAvatar(
                                radius: avatarRadius,
                                backgroundImage: _selectedImage != null
                                    ? FileImage(_selectedImage!)
                                    : NetworkImage(provider.profileImageUrl!)
                                        as ImageProvider,
                              );
                            } else {
                              // If there is no image, display the first letter
                              return CircleAvatar(
                                radius: avatarRadius,
                                backgroundColor: Colors.purple,
                                child: Text(
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
                                ),
                              );
                            }
                          }),
                    Positioned(
                      left: width * 0.32,
                      right: width * 0.12,
                      bottom: width * 0.01,
                      child: GestureDetector(
                        onTap: _selectImage,
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 5,
                                offset: Offset(0, 2),
                              )
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 30,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.01 * height),
                Consumer<ProfileProvider>(
                  builder: (context, providerData, _) {
                    final userName = providerData.currentUser != null &&
                            providerData.currentUser!.name.isNotEmpty
                        ? providerData.currentUser!.name
                        : getUser().name;
                    return Text(
                      userName,
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    );
                  },
                ),
                SizedBox(height: 0.01 * height),
                Consumer<ProfileProvider>(
                  builder: (context, providerData, _) {
                    final userEmail = providerData.currentUser != null &&
                            providerData.currentUser!.email.isNotEmpty
                        ? providerData.currentUser!.email
                        : getUser().email;
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
                  onPressed: provider.isLoading ? null : _updateProfile,
                  child: provider.isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Save Changes', style: TextStyles.buttonLabel),
                ),
                SizedBox(height: 0.02 * height),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, ChangePasswordView.routeName);
                  },
                  child: Text(
                    'Change Password',
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
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
