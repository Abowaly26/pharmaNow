import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pharma_now/core/enitites/medicine_entity.dart';
import 'package:pharma_now/core/utils/app_images.dart';
import '../../../../../core/utils/button_style.dart';
import '../../../../../core/utils/color_manger.dart';
import '../../../../../core/utils/text_styles.dart';
import '../../../../favorites/presentation/views/widgets/favorite_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharma_now/features/order/presentation/cubits/cart_cubit/cart_cubit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../core/widgets/shimmer_loading_placeholder.dart';
import '../../ui_model/entities/cart_item_entity.dart';

class MedicineDetailsViewBody extends StatefulWidget {
  const MedicineDetailsViewBody({
    super.key,
    required this.medicineEntity,
    this.fromCart = false,
    this.fromFavorites = false,
  });

  final MedicineEntity medicineEntity;
  final bool fromCart;
  final bool fromFavorites;

  @override
  State<MedicineDetailsViewBody> createState() =>
      _MedicineDetailsViewBodyState();
}

class _MedicineDetailsViewBodyState extends State<MedicineDetailsViewBody> {
  int _counter = 1;

  CartItemEntity? _getCartItem() {
    return context
        .read<CartCubit>()
        .state
        .cartEntity
        .getCartItem(widget.medicineEntity);
  }

  bool _isInCart() {
    return context
        .read<CartCubit>()
        .state
        .cartEntity
        .isExist(widget.medicineEntity);
  }

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

  // Convert medicine entity to model for storing in favorites
  Map<String, dynamic> _convertEntityToModel() {
    return {
      'id': widget.medicineEntity.code,
      'name': widget.medicineEntity.name,
      'price': widget.medicineEntity.price,
      'imageUrl': widget.medicineEntity.subabaseORImageUrl,
      'pharmacyName': widget.medicineEntity.pharmacyName,
      'pharmacyId': widget.medicineEntity.pharmacyId,
      'pharmcyAddress': widget.medicineEntity.pharmcyAddress,
      'discountRating': widget.medicineEntity.discountRating,
      'isNewProduct': widget.medicineEntity.isNewProduct,
      'description': widget.medicineEntity.description,
      'quantity': widget.medicineEntity.quantity,
    };
  }

  Widget _buildLoadingAnimation() {
    return ShimmerLoadingPlaceholder(
      width: 180.w,
      height: 180.h,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return BlocListener<CartCubit, CartState>(
      listener: (context, state) {
        if (state is CartItemAdded) {
          final screenWidth = MediaQuery.of(context).size.width;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Added to cart',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              backgroundColor: const Color.fromARGB(255, 109, 193, 111),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(42),
              ),
              margin: EdgeInsets.only(
                left: screenWidth * 0.3,
                right: screenWidth * 0.3,
                bottom: 80.h,
              ),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Product Card Section
            _buildProductCardSection(context, height, width),

            BlocBuilder<CartCubit, CartState>(
              builder: (context, cartState) {
                final isItemInCart = _isInCart();
                return Column(
                  children: [
                    SizedBox(height: isItemInCart ? 20.h : 160.h),
                    // Completely Separated Add to Cart Button Section
                    if (!isItemInCart) _buildAddToCartButton(context),
                  ],
                );
              },
            ),

            SizedBox(height: 16.h), // Bottom padding
          ],
        ),
      ),
    );
  }

  // Extracted Product Card Section
  Widget _buildProductCardSection(
      BuildContext context, double height, double width) {
    return Container(
      constraints: BoxConstraints(
        minHeight: height * (widget.fromCart ? 0.4 : 0.6),
        maxHeight: height * 0.8,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background clip path
          ClipPath(
            clipper: BottomInnerOvalClipper(),
            child: Container(
              height: 0.15 * height,
              color: ColorManager.secondaryColor,
            ),
          ),

          // Product card
          Positioned(
            top: 0.02 * height,
            left: 20,
            right: 20,
            child: Material(
              shadowColor: Color(0xff407BFF).withOpacity(0.24),
              elevation: 7,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                decoration: BoxDecoration(
                  color: ColorManager.primaryColor,
                  borderRadius: BorderRadius.circular(24.r),
                ),
                constraints: BoxConstraints(
                  minHeight: height * (widget.fromCart ? 0.2 : 0.65),
                  maxHeight: height * 0.73,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 0.22 * height), // Space for image
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.medicineEntity.name,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // زر المفضلة - يستخدم مكون FavoriteButton المشترك لإضافة/إزالة الدواء من المفضلة
                        // Favorite button - uses the shared FavoriteButton component to add/remove medicine from favorites
                        FavoriteButton(
                          itemId: widget.medicineEntity.code,
                          itemData: _convertEntityToModel(),
                          size: 32,
                          activeColor: Colors.red,
                          inactiveColor: Colors.grey,
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      widget.medicineEntity.pharmacyName ?? "pharmacy name",
                      style: TextStyles.listView_product_name.copyWith(
                        fontSize: 14.sp,
                        color: ColorManager.textInputColor,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14.sp,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          widget.medicineEntity.pharmcyAddress ?? '',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    _buildQuantityStatus(),
                    SizedBox(height: 8.h),
                    BlocBuilder<CartCubit, CartState>(
                      builder: (context, cartState) {
                        final isItemInCart = _isInCart();
                        final cartItem = isItemInCart ? _getCartItem() : null;
                        final quantity =
                            isItemInCart ? (cartItem?.count ?? 1) : _counter;

                        return Row(
                          children: [
                            isItemInCart && cartItem != null
                                ? Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 8.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFF2F4F9),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(32),
                                      ),
                                    ),
                                    child: Text(
                                      "Quantity: $quantity",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      color: Color(0xFFF2F4F9),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(32)),
                                    ),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            if (_counter > 1) {
                                              setState(() {
                                                _counter--;
                                              });
                                            }
                                          },
                                          icon: Icon(
                                            Icons.remove,
                                            size: 24.sp,
                                          ),
                                        ),
                                        SizedBox(width: 0.05 * width),
                                        Text(
                                          "$_counter",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 20.sp,
                                          ),
                                        ),
                                        SizedBox(width: 0.05 * width),
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _counter++;
                                            });
                                          },
                                          icon: Icon(
                                            Icons.add_circle_outlined,
                                            size: 32.sp,
                                            color: ColorManager.secondaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                            Spacer(),
                            Column(
                              children: [
                                if (widget.medicineEntity.discountRating > 0)
                                  Text(
                                    '${(widget.medicineEntity.price * quantity).toStringAsFixed(0)} EGP',
                                    style: TextStyles.listView_product_name
                                        .copyWith(
                                      fontSize: 12.sp,
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey,
                                    ),
                                  ),
                                // Show discounted price or regular price
                                Text(
                                  widget.medicineEntity.discountRating > 0
                                      ? '${_calculateDiscountedPrice(widget.medicineEntity.price.toDouble(), widget.medicineEntity.discountRating.toDouble(), quantity).toStringAsFixed(0)} EGP'
                                      : '${(widget.medicineEntity.price * quantity).toStringAsFixed(0)} EGP',
                                  style: TextStyle(
                                    color: Color(0xFF375DFB),
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          ],
                        );
                      },
                    ),
                    if (!widget.fromCart) ...[
                      SizedBox(height: 10.h),
                      Text(
                        "Description",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    SizedBox(height: 10.h),
                    Flexible(
                      fit: FlexFit.loose,
                      child: ScrollConfiguration(
                        behavior: SmoothScrollBehavior(),
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 4.w, vertical: 4.h),
                            child: Text(
                              widget.medicineEntity.description ??
                                  "Beta Mine is an innovative product that enhances brain health thanks to its rich ingredients, including Vitamin B6, which supports nerve function and maintains heart health.",
                              style: const TextStyle(
                                color: Color(0xffA7AEB5),
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: widget.medicineEntity.isNewProduct ? 16.h : 48.h,
            left: 18.2.w,
            child: widget.medicineEntity.isNewProduct
                ? SvgPicture.asset(
                    Assets.bannerNewProduct,
                    height: 132.h,
                    width: 106.w,
                  )
                : (widget.medicineEntity.discountRating > 0)
                    ? Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          SvgPicture.asset(
                            Assets.gold_banner,
                            height: 32.h,
                            width: 48.w,
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: 1.h,
                              left: 28.0.h,
                            ),
                            child: Text(
                              "${widget.medicineEntity.discountRating}%",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12.sp,
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

          // Product image
          Positioned(
            top: 0.03 * height,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Center(
                  child: Container(
                    height: 180.h,
                    width: 180.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Builder(
                      builder: (context) {
                        final String imageUrl =
                            widget.medicineEntity.subabaseORImageUrl ??
                                'https://i.postimg.cc/2yLfw0qy/image-20.png';

                        return CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.contain,
                          placeholder: (context, url) =>
                              _buildLoadingAnimation(),
                          errorWidget: (context, url, error) => Icon(
                            Icons.image_not_supported,
                            size: 80.sp,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Completely Separated Add to Cart Button
  Widget _buildAddToCartButton(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, cartState) {
        final isItemInCart = _isInCart();

        if (isItemInCart) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          decoration: BoxDecoration(),
          child: SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              style: ButtonStyles.primaryButton,
              onPressed: () {
                context.read<CartCubit>().addMedicineToCartWithCount(
                    widget.medicineEntity, _counter);
              },
              child: Text(
                'Add to Cart',
                style: TextStyles.buttonLabel,
              ),
            ),
          ),
        );
      },
    );
  }

  double _calculateDiscountedPrice(
      double originalPrice, double discountPercentage, int quantity) {
    double totalOriginal = originalPrice * quantity;
    double discountAmount = totalOriginal * (discountPercentage / 100);
    double discountedPrice = totalOriginal - discountAmount;
    return discountedPrice;
  }

  Widget _buildQuantityStatus() {
    final String statusText;
    final Color statusColor;
    final IconData iconData;

    switch (stockStatus) {
      case StockStatus.outOfStock:
        statusText = 'Out of Stock';
        statusColor = Colors.red;
        iconData = Icons.remove_shopping_cart_outlined;
        break;
      case StockStatus.lowStock:
        statusText = 'Low Stock (${widget.medicineEntity.quantity} left)';
        statusColor = Colors.orange;
        iconData = Icons.warning_amber_rounded;
        break;
      case StockStatus.inStock:
        statusText = 'In Stock';
        statusColor = Colors.green;
        iconData = Icons.check_circle_outline_rounded;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            color: statusColor,
            size: 16.sp,
          ),
          SizedBox(width: 8.w),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 14.sp,
              color: statusColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class SmoothScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }
}

class BottomInnerOvalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    path.quadraticBezierTo(
      size.width / 2,
      size.height - 160,
      size.width,
      size.height,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
