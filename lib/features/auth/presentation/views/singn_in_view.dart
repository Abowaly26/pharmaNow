import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/core/services/get_it_service.dart';
import 'package:pharma_now/core/utils/color_manger.dart';
import 'package:pharma_now/core/widgets/custom_app_bar.dart';
import 'package:pharma_now/features/auth/domain/repo/auth_repo.dart';
import 'package:pharma_now/features/auth/presentation/cubits/signin_cubit/signin_cubit.dart';
import 'package:pharma_now/features/auth/presentation/views/widget/singin_view_body_bloc_consumer.dart';

class SignInView extends StatelessWidget {
  const SignInView({super.key});
  static const routeName = 'loginView';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SigninCubit(getIt.get<AuthRepo>()),
      child: Scaffold(
        backgroundColor: ColorManager.primaryColor,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(48.sp),
          child: PharmaAppBar(title: 'Sign in'),
        ),
        body: SigninViewBodyBlocConsumer(),
      ),
    );
  }
}
