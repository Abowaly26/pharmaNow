import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharma_now/core/helper_functions/build_error_bar.dart';
import 'package:pharma_now/core/widgets/bottom_pop_up.dart';
import 'package:pharma_now/features/auth/presentation/views/widget/sign_up_view_body.dart';
import 'package:pharma_now/features/auth/presentation/cubits/sinup_cubit/signup_cubit.dart';
import 'package:pharma_now/features/auth/presentation/views/singn_in_view.dart';

class SignupViewBodyBlocConsumer extends StatelessWidget {
  const SignupViewBodyBlocConsumer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignupCubit, SignupState>(
      listener: (context, state) {
        if (state is SignupSuccess) {
          showSuccessBottomSheet(
              context, 'Your account has been successfully registered', () {
            Navigator.pushReplacementNamed(context, SignInView.routeName);
          });
        }
        if (state is SignupFailure) {
          buildErrorBar(context, state.message);
        }
      },
      builder: (context, state) {
        return SingnUpBody();
      },
    );
  }
}
