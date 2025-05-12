import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:pharma_now/core/utils/app_images.dart';
import 'package:pharma_now/features/favorites/presentation/providers/favorites_provider.dart';

class FavoriteButton extends StatelessWidget {
  final String itemId;
  final Map<String, dynamic> itemData;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;

  const FavoriteButton({
    Key? key,
    required this.itemId,
    required this.itemData,
    this.size = 24,
    this.activeColor = Colors.red,
    this.inactiveColor = Colors.grey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesProvider>(
      builder: (context, provider, child) {
        final isFavorite = provider.isFavorite(itemId);

        return InkWell(
          onTap: () => _toggleFavorite(context, provider),
          child: SvgPicture.asset(
            isFavorite ? Assets.fav : Assets.nFav,
            width: size.w,
            height: size.h,
            // color parameter is not needed as the SVG already has the right colors
          ),
        );
      },
    );
  }

  void _toggleFavorite(BuildContext context, FavoritesProvider provider) {
    provider
        .toggleFavorite(
      itemId: itemId,
      itemData: itemData,
    )
        .then((isNowFavorite) {
      // Show confirmation message (optional)
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              textAlign: TextAlign.center,
              isNowFavorite ? 'added to favorites' : 'removed from favorites',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            backgroundColor: const Color.fromARGB(255, 109, 193, 111),
            width: MediaQuery.of(context).size.width * 0.4,

            // Makes it narrower
            behavior: SnackBarBehavior.floating,
            // This makes it float and allows width customization
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(48),
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }).catchError((e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error occurred: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }
}
