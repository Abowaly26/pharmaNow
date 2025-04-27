import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:pharma_now/features/auth/presentation/views/widget/sing_in_view_body.dart';

import '../../../../../core/helper_functions/build_error_bar.dart';
import '../../../../../core/widgets/bottom_pop_up.dart';
import '../../../../../core/widgets/custom_progress_hud.dart';
import '../../cubits/signin_cubit/signin_cubit.dart';

class SigninViewBodyBlocConsumer extends StatelessWidget {
  const SigninViewBodyBlocConsumer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SigninCubit, SigninState>(
      listener: (context, state) {
        if (state is SigninSuccess) {}

        if (state is SigninFailure) {
          buildErrorBar(context, state.message);
        }
      },
      builder: (context, state) {
        return CustomProgressHUD(
            isLoading: state is SigninLoading ? true : false,
            child: SiginViewBody());
      },
    );
  }
}
