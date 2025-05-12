import 'package:pharma_now/core/utils/app_images.dart';

class BottomNavigationBarEntity {
  final String activeImage;
  final String inActiveImage;
  final String label;

  BottomNavigationBarEntity({
    required this.activeImage,
    required this.inActiveImage,
    required this.label,
  });
}

List<BottomNavigationBarEntity> get bottomNavigationBarEntity => [
      BottomNavigationBarEntity(
        activeImage: Assets.homeIconbold,
        inActiveImage: Assets.homeIconOutline,
        label: 'Home',
      ),
      BottomNavigationBarEntity(
        activeImage: Assets.shoppingCartIconbold,
        inActiveImage: Assets.shoppingCartIconOutline,
        label: 'Cart',
      ),
      BottomNavigationBarEntity(
        activeImage: Assets.favIconbold,
        inActiveImage: Assets.favIconOutline,
        label: 'Favorite',
      ),
      BottomNavigationBarEntity(
        activeImage: Assets.profileIconbold,
        inActiveImage: Assets.profileIconOutline,
        label: 'Profile',
      ),
    ];
