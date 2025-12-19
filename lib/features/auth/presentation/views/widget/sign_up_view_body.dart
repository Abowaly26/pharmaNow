import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/core/utils/button_style.dart';
import 'package:pharma_now/core/utils/color_manger.dart';
import 'package:pharma_now/core/utils/app_validation.dart';
import 'package:pharma_now/core/utils/text_styles.dart';
import 'package:pharma_now/features/auth/presentation/views/sign_in_view.dart';

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
                userName = p0!;
              },
              validator: AppValidation.validateUserName,
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
                validator: AppValidation.validateEmail,
                lable: 'Email',
                icon: Assets.emailIcon,
                hint: 'Enter your email'),
            SizedBox(
              height: 16.h,
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
              validator: AppValidation.validatePassword,
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
              validator: (value) => AppValidation.validateConfirmPassword(
                value,
                passwordController.text,
              ),
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
