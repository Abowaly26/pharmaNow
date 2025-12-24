import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharma_now/core/helper_functions/build_error_bar.dart'
    show showCustomBar, MessageType;
import 'package:pharma_now/core/widgets/bottom_pop_up.dart';
import 'package:pharma_now/features/auth/presentation/views/widget/sign_in_view_body.dart';
import 'package:pharma_now/features/home/presentation/views/main_view.dart';
import 'package:pharma_now/features/auth/presentation/cubits/signin_cubit/signin_cubit.dart';
import 'package:pharma_now/features/auth/presentation/views/verification_view_signup.dart';

class SigninViewBodyBlocConsumer extends StatefulWidget {
  const SigninViewBodyBlocConsumer({
    super.key,
  });

  @override
  State<SigninViewBodyBlocConsumer> createState() =>
      _SigninViewBodyBlocConsumerState();
}

class _SigninViewBodyBlocConsumerState
    extends State<SigninViewBodyBlocConsumer> {
  bool _hasShownAccountDeletedBar = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final accountDeleted = args?['accountDeleted'] ?? false;

    if (accountDeleted && !_hasShownAccountDeletedBar) {
      _hasShownAccountDeletedBar = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showCustomBar(
          context,
          'Your account has been deleted or disabled. Please contact support or sign in with a different account.',
          type: MessageType.warning,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SigninCubit, SigninState>(
      listener: (context, state) {
        if (state is SigninSuccess) {
          showSuccessBottomSheet(
            context,
            'Signed in successfully',
            () {
              Navigator.pushReplacementNamed(context, MainView.routeName);
            },
            isDismissible: false,
            enableDrag: false,
            buttonText: 'Go to Home',
          );
        }
        if (state is SigninFailure) {
          if (state.message.contains('verify your email')) {
            // Instead of showing a snackbar (which causes the overlay glitch),
            // navigate to verification screen directly.
            // showCustomBar(context, state.message);
            Navigator.pushReplacementNamed(
              context,
              VerificationView.routeName,
              arguments: {'fromSignIn': true, 'message': state.message},
            );
          } else {
            showCustomBar(context, state.message);
          }
        }
      },
      builder: (context, state) {
        return SiginViewBody();
      },
    );
  }
}
