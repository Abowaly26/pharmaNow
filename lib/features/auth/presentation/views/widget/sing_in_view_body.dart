import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/core/utils/color_manger.dart';
import 'package:pharma_now/core/utils/text_style.dart';
import 'package:pharma_now/core/widgets/or_divider.dart';
import 'package:pharma_now/core/widgets/anotherStepLogin.dart';
import 'package:pharma_now/core/widgets/password_field.dart';
import 'package:pharma_now/features/auth/presentation/views/forget_password_view.dart';
import 'package:pharma_now/features/auth/presentation/views/singn_up_view.dart';
import 'package:pharma_now/core/widgets/custom_text_field.dart';
import 'package:pharma_now/features/home/presentation/views/home_view.dart';

import '../../../../../core/utils/app_images.dart';
import '../../../../../core/utils/button_style.dart';
import '../../../../../core/widgets/bottom_pop_up.dart';
import '../../cubits/signin_cubit/signin_cubit.dart';

class SiginViewBody extends StatefulWidget {
  const SiginViewBody({super.key});

  @override
  State<SiginViewBody> createState() => _SiginViewBodyState();
}

class _SiginViewBodyState extends State<SiginViewBody> {
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  late String email, password;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  // Define TextEditingControllers to manage input fields
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  @override
  void dispose() {
    // Clean up controllers when the screen is disposed
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    // Validate email format using RegExp
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // Function to validate password
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 32.h),
        child: Form(
          key: formKey,
          autovalidateMode: autovalidateMode,
          child: Column(children: [
            CustomTextField(
                onSaved: (p0) {
                  email = p0!;
                },
                validator: validateEmail,
                controller: emailController,
                textInputType: TextInputType.emailAddress,
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
              validator: validatePassword,
              controller: passwordController,
              textInputType: TextInputType.visiblePassword,
              lable: 'Password',
              icon: Assets.passwordIcon,
              hint: 'Enter your password',
            ),
            SizedBox(
              height: 16.h,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                splashColor: ColorManager.colorLines,
                onTap: () {
                  Navigator.pushReplacementNamed(
                      context, ForgetPasswordView.routeName);
                },
                child: Text(
                  'Forgot Password?',
                  style: TextStyles.forgetPassword,
                ),
              ),
            ),
            SizedBox(
              height: 25.h,
            ),
            ElevatedButton(
              style: ButtonStyles.primaryButton,
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();

                  context.read<SigninCubit>().signin(email, password);
                } else {
                  autovalidateMode = AutovalidateMode.always;
                  setState(() {});
                }
                // Navigator.pushReplacementNamed(context, HomeView.routeName);
              },
              child: Text(
                'Sign In',
                style: TextStyles.buttonLabel,
              ),
            ),
            SizedBox(
              height: 25.h,
            ),
            OrDivider(),
            SizedBox(
              height: 25.h,
            ),
            AnotherStepLogin(
              onPressed: () {
                context.read<SigninCubit>().signinWithGoogle();
              },
              text: 'Continue with Google',
              icon: Assets.google_Icon,
            ),
            SizedBox(
              height: 15.h,
            ),
            AnotherStepLogin(
              onPressed: () {
                // context.read<SigninCubit>().signinWithFacbook();
              },
              text: 'Continue with Facebook',
              icon: Assets.facebook_Icon,
            ),
            SizedBox(
              height: 190.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Don’t have an account?',
                      style: TextStyles.callToActionText,
                    ),
                    InkWell(
                      splashColor: ColorManager.colorLines,
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    SingnUpView(),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      child: Text(' Sign Up',
                          style: TextStyles.callToActionSignUP),
                    ),
                    SizedBox(
                      height: 8,
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
