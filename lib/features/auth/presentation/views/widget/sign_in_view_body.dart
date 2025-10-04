import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/core/utils/color_manger.dart';
import 'package:pharma_now/core/utils/text_styles.dart';
import 'package:pharma_now/core/widgets/or_divider.dart';
import 'package:pharma_now/core/widgets/anotherStepLogin.dart';
import 'package:pharma_now/core/widgets/password_field.dart';
import 'package:pharma_now/features/auth/presentation/views/forget_password_view.dart';
import 'package:pharma_now/features/auth/presentation/views/singn_up_view.dart';
import 'package:pharma_now/core/widgets/custom_text_field.dart';

import '../../../../../core/utils/app_images.dart';
import '../../../../../core/utils/button_style.dart';
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
                textInputType: TextInputType.emailAddress,
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
            // AnotherStepLogin(
            //   onPressed: () {
            //     // context.read<SigninCubit>().signinWithFacbook();
            //   },
            //   text: 'Continue with Facebook',
            //   icon: Assets.facebook_Icon,
            // ),
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
                      height: 8.h,
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
