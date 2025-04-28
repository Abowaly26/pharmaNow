import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:pharma_now/features/auth/presentation/views/widget/singn_up_view_body.dart';

import '../../../../../core/helper_functions/build_error_bar.dart';
import '../../../../../core/widgets/bottom_pop_up.dart';
import '../../cubits/sinup_cubit/signup_cubit.dart';
import '../singn_in_view.dart';

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
        return ModalProgressHUD(
            inAsyncCall: state is SignupLoading ? true : false,
            child: SingnUpBody());
      },
    );
  }
}
