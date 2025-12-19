import 'package:flutter/material.dart';
import 'package:pharma_now/features/favorites/presentation/views/favorites.dart';
import 'package:pharma_now/features/home/presentation/views/widgets/home_view.dart';

import '../../../../order/presentation/views/cart_view.dart';
import '../../../../profile/presentation/views/profile_view.dart';

class MainViewbody extends StatelessWidget {
  const MainViewbody({
    super.key,
    required this.CurrentViewIndex,
  });

  final int CurrentViewIndex;

  @override
  Widget build(BuildContext context) {
    return IndexedStack(index: CurrentViewIndex, children: [
      const HomeView(),
      const CartView(),
      const FavoriteView(),
      const ProfileView(),
    ]);
  }
}
