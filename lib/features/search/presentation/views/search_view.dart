import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/utils/color_manger.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../home/presentation/views/main_view.dart';
import '../cubit/cubit/search_cubit.dart';
import 'widgets/search_view_body.dart';
import 'package:pharma_now/features/order/presentation/cubits/cart_cubit/cart_cubit.dart';

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  static const routeName = 'SearchView';

  @override
  Widget build(BuildContext context) {
    // Get the SearchCubit and CartCubit from the service locator
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => GetIt.instance<SearchCubit>()),
        BlocProvider.value(value: GetIt.instance<CartCubit>()),
      ],
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: ColorManager.primaryColor,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(48.sp),
            child: PharmaAppBar(
              isBack: true,
              onPressed: () {
                Navigator.pushReplacementNamed(context, MainView.routeName);
              },
              title: 'Search',
            ),
          ),
          body: const SearchViewBody(),
        ),
      ),
    );
  }
}
