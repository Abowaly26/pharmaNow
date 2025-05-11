import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/core/services/get_it_service.dart';
import 'package:pharma_now/features/auth/domain/repo/auth_repo.dart';
import 'package:pharma_now/features/auth/presentation/cubits/sinup_cubit/signup_cubit.dart';

import 'package:pharma_now/features/auth/presentation/views/widget/sinup_view_body_bloc_consumer.dart';

import '../../../../core/utils/color_manger.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class SingnUpView extends StatelessWidget {
  const SingnUpView({super.key});
  static const routeName = 'singUpView';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignupCubit(getIt<AuthRepo>()),
      child: Scaffold(
        backgroundColor: ColorManager.primaryColor,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(48.sp),
          child: PharmaAppBar(title: 'Sign Up'),
        ),
        body: SignupViewBodyBlocConsumer(),
      ),
    );
  }
}
