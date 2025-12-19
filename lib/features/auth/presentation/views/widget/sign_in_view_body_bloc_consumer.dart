import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharma_now/core/helper_functions/build_error_bar.dart'
    show showCustomBar;
import 'package:pharma_now/core/widgets/bottom_pop_up.dart';
import 'package:pharma_now/features/auth/presentation/views/widget/sign_in_view_body.dart';
import 'package:pharma_now/features/home/presentation/views/main_view.dart';
import 'package:pharma_now/features/auth/presentation/cubits/signin_cubit/signin_cubit.dart';

class SigninViewBodyBlocConsumer extends StatelessWidget {
  const SigninViewBodyBlocConsumer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SigninCubit, SigninState>(
      listener: (context, state) {
        if (state is SigninSuccess) {
          showSuccessBottomSheet(context, 'Signed in successfully', () {
            Navigator.pushReplacementNamed(context, MainView.routeName);
          });
        }
        if (state is SigninFailure) {
          showCustomBar(context, state.message);
        }
      },
      builder: (context, state) {
        return SiginViewBody();
      },
    );
  }
}
