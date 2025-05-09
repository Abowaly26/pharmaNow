import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/utils/color_manger.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../cubit/cubit/search_cubit.dart';
import 'widgets/search_view_body.dart';

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  static const routeName = 'SearchView';

  @override
  Widget build(BuildContext context) {
    // Get the SearchCubit from the service locator
    return BlocProvider(
      create: (context) => GetIt.instance<SearchCubit>(),
      child: Scaffold(
        backgroundColor: ColorManager.primaryColor,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(48.sp),
          child: const PharmaAppBar(
            title: 'Search',
          ),
        ),
        body: const SearchViewBody(),
      ),
    );
  }
}
