import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pharma_now/core/helper_functions/build_error_bar.dart';
import 'package:provider/provider.dart';
import 'package:pharma_now/features/order/presentation/cubits/cart_cubit/cart_cubit.dart';
import 'package:pharma_now/core/enitites/medicine_entity.dart';
import 'package:pharma_now/core/models/medicine_model.dart';
import 'package:pharma_now/features/home/presentation/views/medicine_details_view.dart';
import 'package:pharma_now/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:pharma_now/core/utils/text_styles.dart';
import 'package:pharma_now/core/utils/color_manger.dart';
import 'package:pharma_now/core/utils/app_images.dart' show Assets;
import 'package:pharma_now/core/widgets/custom_dialog.dart';
import 'package:pharma_now/core/widgets/shimmer_loading_placeholder.dart';
import 'package:pharma_now/core/widgets/premium_loading_indicator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoriteViewBody extends StatefulWidget {
  const FavoriteViewBody({super.key});

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
    return BlocListener<CartCubit, CartState>(
      listener: (context, state) {
        if (state is CartItemAdded) {
          showCustomBar(
            context,
            'Added to cart',
            duration: const Duration(seconds: 1),
            type: MessageType.success,
          );
        } else if (state is CartItemRemoved) {
          showCustomBar(
            context,
            'Removed from cart',
            duration: const Duration(seconds: 1),
            type: MessageType.success,
          );
        } else if (state is CartError) {
          showCustomBar(
            context,
            state.message,
            duration: const Duration(seconds: 2),
            type: MessageType.error,
          );
        }
      },
      child: Container(
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
              Consumer<FavoritesProvider>(
                builder: (context, favoritesProvider, child) {
                  if (favoritesProvider.favorites.isEmpty) {
                    return const SizedBox
                        .shrink(); // Return empty space if no favorites
                  }
                  return Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => _showClearConfirmationDialog(context),
                      icon: Icon(
                        Icons.delete_sweep_outlined,
                        color: ColorManager.redColorF5,
                      ),
                      label: Text(
                        'Clear All',
                        style: TextStyles.sectionTitle.copyWith(
                          color: ColorManager.redColorF5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 8.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          side: BorderSide(
                            color:
                                ColorManager.redColorF5.withValues(alpha: 0.5),
                            width: 1.w,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 8.h),
              // Favorites content
              Expanded(
                child: Consumer<FavoritesProvider>(
                  builder: (context, favoritesProvider, child) {
                    if (favoritesProvider.isLoading) {
                      return const Center(child: PremiumLoadingIndicator());
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
                        pharmacyName: item['pharmacyName'] as String? ??
                            'Unknown Pharmacy',
                        pharmacyId: (item['pharmacyId'] as num?)?.toInt() ?? 0,
                        pharmcyAddress: item['pharmcyAddress'] as String? ?? '',
                        reviews: [], // Add empty reviews list
                        sellingCount:
                            (item['sellingCount'] as num?)?.toInt() ?? 0,
                        discountRating:
                            (item['discountRating'] as num?)?.toInt() ?? 0,
                        avgRating:
                            (item['avgRating'] as num?)?.toDouble() ?? 0.0,
                      );
                    }).toList();

                    return _buildGridView(favorites);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClearConfirmationDialog(BuildContext context) {
    CustomDialog.show(
      context,
      title: 'Clear All Favorites',
      content: 'Are you sure you want to delete all your favorites?',
      confirmText: 'Clear',
      confirmColor: ColorManager.redColorF5,
      icon: Icon(
        Icons.delete_sweep_outlined,
        color: ColorManager.redColorF5,
        size: 40.sp,
      ),
      onConfirm: () {
        Provider.of<FavoritesProvider>(context, listen: false)
            .clearAllFavorites();
        Navigator.of(context).pop();
        if (context.mounted) {
          showCustomBar(
            context,
            'Favorite items have been deleted',
            duration: const Duration(seconds: 2),
            type: MessageType.success,
          );
        }
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 24.h),
          SvgPicture.asset(
            Assets.favState,
            height: 280.h,
            width: 280.w,
          ),
          SizedBox(height: 2.h),
          Text(
            'Your favorite medicines will appear here',
            style: TextStyles.description
                .copyWith(color: Colors.grey.shade700, fontSize: 14.sp),
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
class MedicineListViewItem extends StatefulWidget {
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
  State<MedicineListViewItem> createState() => _MedicineListViewItemState();
}

class _MedicineListViewItemState extends State<MedicineListViewItem> {
  // Getter to determine stock status from medicine quantity
  StockStatus get stockStatus {
    if (widget.medicineEntity.quantity <= 0) {
      return StockStatus.outOfStock;
    }
    if (widget.medicineEntity.quantity < 10) {
      return StockStatus.lowStock;
    }
    return StockStatus.inStock;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          MedicineDetailsView.routeName,
          arguments: {
            'medicineEntity': widget.medicineEntity,
            'fromFavorites': true,
          },
        );
      },
      child: Padding(
        padding: EdgeInsetsDirectional.only(end: 12.w),
        child: Column(
          children: [
            _buildTopContainer(context),
            _buildBottomContainer(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTopContainer(BuildContext context) {
    return Container(
      width: 162.w,
      height: 90.h,
      decoration: BoxDecoration(
        color: widget.index.isOdd
            ? ColorManager.lightBlueColorF5C
            : ColorManager.lightGreenColorF5C,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.r),
          topRight: Radius.circular(12.r),
        ),
        border: Border.all(color: ColorManager.greyColorC6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
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
              child: widget.medicineEntity.subabaseORImageUrl == null ||
                      widget.medicineEntity.subabaseORImageUrl!.isEmpty
                  ? Container(
                      color: ColorManager.textInputColor.withValues(alpha: 0.2),
                      height: 80.h,
                      width: 80.w,
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: CachedNetworkImage(
                        imageUrl: widget.medicineEntity.subabaseORImageUrl!,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => _buildLoadingAnimation(),
                        errorWidget: (context, url, error) => Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 55.sp,
                            color: Colors.grey.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          Positioned(bottom: 4.h, right: 4.w, child: _buildStockIndicator()),
          // Banner logic - Show either New banner OR Discount banner
          Positioned(
            top: widget.medicineEntity.isNewProduct ? 0 : 8.h,
            left: 0,
            child: widget.medicineEntity.isNewProduct
                ? SvgPicture.asset(
                    Assets.bannerNewProduct,
                    height: 80.h,
                    width: 106.w,
                  )
                : (widget.medicineEntity.discountRating > 0)
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
                              "${widget.medicineEntity.discountRating}%",
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
                      final code = widget.medicineEntity.code;

                      // Remove the item from favorites
                      await favoritesProvider.removeFromFavorites(code);

                      // Show success message
                      if (context.mounted) {
                        showCustomBar(
                          context,
                          'Item successfully removed from favorites',
                          duration: const Duration(seconds: 1),
                          type: MessageType.success,
                        );
                      }

                      // Notify the parent widget of the change
                      if (widget.onFavoriteChanged != null) {
                        widget.onFavoriteChanged!(false);
                      }
                    } catch (e) {
                      // Show error message
                      if (context.mounted) {
                        showCustomBar(
                          context,
                          'Error occurred: ${e.toString()}',
                          type: MessageType.error,
                          duration: const Duration(seconds: 2),
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
            color: Colors.black.withValues(alpha: 0.1),
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.medicineEntity.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyles.listView_product_name,
                  ),
                ),
                SizedBox(width: 6.w),
                Padding(
                  padding: EdgeInsets.only(right: 4.r),
                  child: _buildQuantityStatus(),
                ),
              ],
            ),
            Text(
              widget.medicineEntity.pharmacyName,
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
                      if (widget.medicineEntity.discountRating > 0)
                        Text(
                          '${widget.medicineEntity.price} EGP',
                          style: TextStyles.listView_product_name.copyWith(
                            fontSize: 10.sp,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                      // Show discounted price or regular price
                      Text(
                        widget.medicineEntity.discountRating > 0
                            ? '${_calculateDiscountedPrice(widget.medicineEntity.price.toDouble(), widget.medicineEntity.discountRating.toDouble()).split('.')[0]} EGP'
                            : '${widget.medicineEntity.price} EGP',
                        style: TextStyles.listView_product_name.copyWith(
                          fontSize: 11.sp,
                          color: const Color(0xFF20B83A),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 8.r),
                    child: BlocBuilder<CartCubit, CartState>(
                      builder: (context, cartState) {
                        final cartEntity = cartState.cartEntity;
                        final isInCart =
                            cartEntity.isExist(widget.medicineEntity);
                        final isLoading = cartState.loadingMedicineIds
                            .contains(widget.medicineEntity.code);

                        return GestureDetector(
                          onTap: (isInCart || isLoading)
                              ? null
                              : () {
                                  context
                                      .read<CartCubit>()
                                      .addMedicineToCart(widget.medicineEntity);
                                },
                          child: Opacity(
                            opacity: isInCart ? 0.5 : 1.0,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SvgPicture.asset(
                                  Assets.frameCart,
                                  width: 32.w,
                                  height: 32.h,
                                ),
                                isLoading
                                    ? SizedBox(
                                        width: 12.w,
                                        height: 12.h,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            ColorManager.primaryColor,
                                          ),
                                        ),
                                      )
                                    : SvgPicture.asset(
                                        Assets.cartPlus,
                                        width: 24.w,
                                        height: 24.h,
                                      ),
                              ],
                            ),
                          ),
                        );
                      },
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
      width: 80.w,
      height: 80.h,
    );
  }

  Widget _buildStockIndicator() {
    final Color indicatorColor;
    switch (stockStatus) {
      case StockStatus.outOfStock:
        indicatorColor = Colors.red;
        break;
      case StockStatus.lowStock:
        indicatorColor = Colors.orange;
        break;
      case StockStatus.inStock:
        indicatorColor = Colors.green;
        break;
    }

    return Container(
      width: 12.w,
      height: 12.h,
      decoration: BoxDecoration(
        color: indicatorColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.0),
        boxShadow: [
          BoxShadow(
            color: indicatorColor.withValues(alpha: 0.3),
            blurRadius: 4.r,
            spreadRadius: 1.r,
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityStatus() {
    final String statusText;
    final Color statusColor;

    switch (stockStatus) {
      case StockStatus.outOfStock:
        statusText = 'Out';
        statusColor = Colors.red;
        break;
      case StockStatus.lowStock:
        statusText = 'Low Stock';
        statusColor = Colors.orange;
        break;
      case StockStatus.inStock:
        statusText = 'Stock';
        statusColor = Colors.green;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 8.sp,
          color: statusColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // Helper method to calculate the discounted price
  String _calculateDiscountedPrice(
      double originalPrice, double discountPercentage) {
    double discountAmount = originalPrice * (discountPercentage / 100);
    double discountedPrice = originalPrice - discountAmount;
    return discountedPrice.toStringAsFixed(2).replaceAll(RegExp(r'\.0+$'), '');
  }
}
