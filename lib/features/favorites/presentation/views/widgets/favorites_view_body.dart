import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:pharma_now/core/enitites/medicine_entity.dart';
import 'package:pharma_now/core/models/medicine_model.dart';
import 'package:pharma_now/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:pharma_now/core/utils/text_styles.dart';
import 'package:pharma_now/core/utils/color_manger.dart';
import 'package:pharma_now/core/utils/app_images.dart' show Assets;
import 'package:pharma_now/core/widgets/shimmer_loading_placeholder.dart';

class FavoriteViewBody extends StatefulWidget {
  const FavoriteViewBody({Key? key}) : super(key: key);

  @override
  State<FavoriteViewBody> createState() => _FavoriteViewBodyState();
}

class _FavoriteViewBodyState extends State<FavoriteViewBody> {
  @override
  void initState() {
    super.initState();
    // Update favorites list when the page starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FavoritesProvider>(context, listen: false).refreshFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorManager.primaryColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.r),
          topRight: Radius.circular(30.r),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          children: [
            // Favorites content
            Expanded(
              child: Consumer<FavoritesProvider>(
                builder: (context, favoritesProvider, child) {
                  if (favoritesProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (favoritesProvider.favorites.isEmpty) {
                    return _buildEmptyState();
                  }

                  // Convert Map<String, dynamic> to MedicineModel objects
                  final favorites = favoritesProvider.favorites.map((item) {
                    return MedicineModel(
                      name: item['name'] as String? ?? 'Unknown',
                      description: item['description'] as String? ?? '',
                      code: item['code'] as String? ?? '',
                      quantity: item['quantity'] as int? ?? 0,
                      isNewProduct: item['isNewProduct'] as bool? ?? false,
                      price: item['price'] as num? ?? 0,
                      subabaseORImageUrl: item['imageUrl'] as String?,
                      pharmacyName:
                          item['pharmacyName'] as String? ?? 'Unknown Pharmacy',
                      pharmacyId: (item['pharmacyId'] as num?)?.toInt() ?? 0,
                      pharmcyAddress: item['pharmcyAddress'] as String? ?? '',
                      reviews: [], // Add empty reviews list
                      sellingCount:
                          (item['sellingCount'] as num?)?.toInt() ?? 0,
                      discountRating:
                          (item['discountRating'] as num?)?.toInt() ?? 0,
                      avgRating: (item['avgRating'] as num?)?.toDouble() ?? 0.0,
                    );
                  }).toList();

                  return _buildGridView(favorites);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 60.h),
          Icon(
            Icons.favorite_border,
            size: 70.sp,
            color: Colors.blue.shade800,
          ),
          SizedBox(height: 16.h),
          Text(
            '',
            style: TextStyles.title
                .copyWith(fontSize: 18.sp, color: Colors.black87),
          ),
          SizedBox(height: 8.h),
          Text(
            'Your favorite medicines will appear here',
            style: TextStyles.description.copyWith(color: Colors.grey.shade700),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(List<MedicineModel> favorites) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.9,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 10.h,
      ),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        // Convert model to entity for the MedicineListViewItem
        final medicineEntity = _convertModelToEntity(favorites[index]);

        return MedicineListViewItem(
          key: ValueKey(medicineEntity.code), // Key for proper rebuilding
          index: index,
          medicineEntity: medicineEntity,
          onFavoriteChanged: (_) {
            // Update UI after removing the item from favorites
            setState(() {});
          },
        );
      },
    );
  }

  // Helper method to convert MedicineModel to MedicineEntity
  MedicineEntity _convertModelToEntity(MedicineModel model) {
    return MedicineEntity(
      name: model.name,
      description: model.description,
      code: model.code,
      quantity: model.quantity,
      isNewProduct: model.isNewProduct,
      price: model.price,
      subabaseORImageUrl: model.subabaseORImageUrl,
      pharmacyName: model.pharmacyName,
      pharmacyId: model.pharmacyId,
      pharmcyAddress: model.pharmcyAddress,
      reviews: [], // Initialize with empty list since we don't need reviews for favorites functionality
      sellingCount: model.sellingCount,
      discountRating: model.discountRating,
      avgRating: model.avgRating,
      ratingCount: 0,
    );
  }
}

// Medicine List View Item Widget
class MedicineListViewItem extends StatelessWidget {
  final int index;
  final MedicineEntity medicineEntity;
  // Optional callback for when favorite status changes
  final Function(bool)? onFavoriteChanged;

  const MedicineListViewItem({
    super.key,
    required this.index,
    required this.medicineEntity,
    this.onFavoriteChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(end: 12.w),
      child: Column(
        children: [
          _buildTopContainer(context),
          _buildBottomContainer(context),
        ],
      ),
    );
  }

  Widget _buildTopContainer(BuildContext context) {
    return Container(
      width: 162.w,
      height: 90.h,
      decoration: BoxDecoration(
        color: index.isOdd
            ? ColorManager.lightBlueColorF5C
            : ColorManager.lightGreenColorF5C,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.r),
          topRight: Radius.circular(12.r),
        ),
        border: Border.all(color: ColorManager.greyColorC6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(5.r),
            child: Center(
              child: medicineEntity.subabaseORImageUrl == null
                  ? Container(
                      color: ColorManager.textInputColor.withOpacity(0.2),
                      height: 80.h,
                      width: 80.w,
                    )
                  : Image.network(
                      medicineEntity.subabaseORImageUrl!,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return _buildLoadingAnimation();
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(child: Text('No image available')),
                    ),
            ),
          ),
          // Banner logic - Show either New banner OR Discount banner
          Positioned(
            top: medicineEntity.isNewProduct ? 0 : 8.h,
            left: 0,
            child: medicineEntity.isNewProduct
                ? SvgPicture.asset(
                    Assets.bannerNewProduct,
                    height: 80.h,
                    width: 106.w,
                  )
                : (medicineEntity.discountRating > 0)
                    ? Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          SvgPicture.asset(
                            Assets.gold_banner,
                            height: 24.h,
                            width: 48.w,
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: 1.h,
                              left: 20.0.h,
                            ),
                            child: Text(
                              "${medicineEntity.discountRating}%",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 9.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      )
                    : Container(), // No banner if neither new nor has discount
          ),
          // Favorite icon - Fixed implementation to properly remove items
          Positioned(
            top: 8.h,
            right: 8.w,
            child: Consumer<FavoritesProvider>(
              builder: (context, favoritesProvider, _) {
                return GestureDetector(
                  onTap: () async {
                    try {
                      // Use the correct code for the item
                      final code = medicineEntity.code;

                      // Remove the item from favorites
                      await favoritesProvider.removeFromFavorites(code);

                      // Show success message
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Item successfully removed from favorites'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }

                      // Notify the parent widget of the change
                      if (onFavoriteChanged != null) {
                        onFavoriteChanged!(false);
                      }
                    } catch (e) {
                      // Show error message
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error occurred: ${e.toString()}'),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  },
                  child: SvgPicture.asset(
                    Assets.fav, // Filled heart icon (favorite)
                    width: 24.w,
                    height: 24.h,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomContainer(BuildContext context) {
    return Container(
      width: 161.w,
      height: 90.h,
      decoration: BoxDecoration(
        color: ColorManager.buttom_info,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12.r),
          bottomRight: Radius.circular(12.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 8.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8.h),
            SizedBox(
              width: 175.w,
              child: Text(
                medicineEntity.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyles.listView_product_name,
              ),
            ),
            Text(
              medicineEntity.pharmacyName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.listView_product_name.copyWith(
                fontSize: 10.sp,
                color: ColorManager.textInputColor,
              ),
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.only(left: 4.r),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Show the original price with strikethrough if there's a discount
                      if (medicineEntity.discountRating > 0)
                        Text(
                          '${medicineEntity.price} EGP',
                          style: TextStyles.listView_product_name.copyWith(
                            fontSize: 10.sp,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                      // Show discounted price or regular price
                      Text(
                        medicineEntity.discountRating > 0
                            ? '${_calculateDiscountedPrice(medicineEntity.price.toDouble(), medicineEntity.discountRating.toDouble()).split('.')[0]} EGP'
                            : '${medicineEntity.price} EGP',
                        style: TextStyles.listView_product_name.copyWith(
                          fontSize: 11.sp,
                          color: const Color(0xFF20B83A),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 8.r, right: 8.r),
                    child: GestureDetector(
                      onTap: () {
                        // Add to cart functionality
                      },
                      child: SvgPicture.asset(
                        Assets.cart,
                        width: 32.w,
                        height: 32.h,
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingAnimation() {
    return ShimmerLoadingPlaceholder(
        width: 100.w,
        height: 120.h,
        baseColor: Colors.white.withOpacity(0.2),
        highlightColor: ColorManager.secondaryColor.withOpacity(0.4));
  }

  // Helper method to calculate the discounted price
  String _calculateDiscountedPrice(
      double originalPrice, double discountPercentage) {
    double discountAmount = originalPrice * (discountPercentage / 100);
    double discountedPrice = originalPrice - discountAmount;
    return discountedPrice.toStringAsFixed(2).replaceAll(RegExp(r'\.0+$'), '');
  }

  // Helper method to convert MedicineEntity to MedicineModel for favorites functionality
  MedicineModel _convertEntityToModel(MedicineEntity entity) {
    return MedicineModel(
      name: entity.name,
      description: entity.description,
      code: entity.code,
      quantity: entity.quantity,
      isNewProduct: entity.isNewProduct,
      price: entity.price,
      subabaseORImageUrl: entity.subabaseORImageUrl,
      pharmacyName: entity.pharmacyName,
      pharmacyId: entity.pharmacyId,
      pharmcyAddress: entity.pharmcyAddress,
      reviews: [], // Initialize with empty list
      sellingCount: entity.sellingCount,
      discountRating: entity.discountRating,
      avgRating: entity.avgRating,
    );
  }
}
