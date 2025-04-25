import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/core/utils/button_style.dart';
import 'package:pharma_now/core/utils/color_manger.dart';
import 'package:pharma_now/core/utils/text_style.dart';
import 'package:pharma_now/core/widgets/anotherStepLogin.dart';
import 'package:pharma_now/core/widgets/or_divider.dart';
import 'package:pharma_now/features/auth/presentation/views/singn_in_view.dart';
import 'package:pharma_now/features/auth/presentation/views/verification_view_signup.dart';

import 'package:pharma_now/core/widgets/custom_text_field.dart';

import '../../../../../core/utils/app_images.dart';
import '../../../../../core/widgets/password_field.dart';
import '../../cubits/sinup_cubit/signup_cubit.dart';

class SingnUpBody extends StatefulWidget {
  const SingnUpBody({super.key});

  @override
  State<SingnUpBody> createState() => _SingnUpBodyState();
}

class _SingnUpBodyState extends State<SingnUpBody> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  late String email, userName, password;
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  String? validateUserName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    if (value.length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }

  // Email validation
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }

    // Regular expression for email validation
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // Password validation
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    // Check for uppercase, lowercase, and number
    bool hasUppercase = value.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = value.contains(RegExp(r'[a-z]'));
    bool hasDigits = value.contains(RegExp(r'[0-9]'));

    if (!hasUppercase || !hasLowercase || !hasDigits) {
      return 'Password must contain uppercase, lowercase, and number';
    }

    return null;
  }

  // Confirm password validation
  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        child: Form(
          key: formKey,
          autovalidateMode: autovalidateMode,
          child: Column(children: [
            CustomTextField(
              onSaved: (p0) {
                userName = p0!;
              },
              validator: validateUserName,
              lable: 'Name',
              icon: Assets.nameIcon,
              hint: 'Enter your name',
              textInputType: TextInputType.name,
            ),
            SizedBox(
              height: 16,
            ),
            CustomTextField(
                textInputType: TextInputType.emailAddress,
                onSaved: (p0) {
                  email = p0!;
                },
                validator: validateEmail,
                lable: 'Email',
                icon: Assets.emailIcon,
                hint: 'Enter your email'),
            SizedBox(
              height: 16,
            ),
            PasswordFiled(
              onSaved: (p0) {
                password = p0!;
              },
              lable: 'Password',
              icon: Assets.passwordIcon,
              hint: 'Enter your password',
              textInputType: TextInputType.visiblePassword,
              controller: passwordController,
              validator: validatePassword,
            ),
            SizedBox(
              height: 16.h,
            ),
            PasswordFiled(
              onSaved: (p0) {
                password = p0!;
              },
              lable: 'Confirm Password',
              icon: Assets.passwordIcon,
              hint: 'Enter your password',
              textInputType: TextInputType.visiblePassword,
              controller: confirmPasswordController,
              validator: validateConfirmPassword,
            ),
            SizedBox(
              height: 24.h,
            ),
            ElevatedButton(
              style: ButtonStyles.primaryButton,
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  context.read<SignupCubit>().createUserWithEmailAndPassword(
                      email, password, userName);
                } else {
                  setState(() {
                    autovalidateMode = AutovalidateMode.always;
                  });
                }

                // Navigator.pushReplacementNamed(
                //     context, VerificationView.routeName);
              },
              child: Text(
                'Sign Up',
                style: TextStyles.buttonLabel,
              ),
            ),
            SizedBox(
              height: 225.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Already have an account?',
                      style: TextStyles.callToActionText,
                    ),
                    InkWell(
                      splashColor: ColorManager.colorLines,
                      onTap: () {
                        Navigator.pushReplacementNamed(
                            context, SignInView.routeName);
                      },
                      child: Text(' Sign In',
                          style: TextStyles.callToActionSignUP),
                    ),
                    SizedBox(
                      height: 24.h,
                    )
                  ],
                )
              ],
            )
          ]),
        ),
      ),
    );
  }
}
