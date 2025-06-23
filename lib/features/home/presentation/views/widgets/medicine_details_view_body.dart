import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pharma_now/core/enitites/medicine_entity.dart';
import 'package:pharma_now/core/utils/app_images.dart';
import '../../../../../core/utils/button_style.dart';
import '../../../../../core/utils/color_manger.dart';
import '../../../../../core/utils/text_styles.dart';
import '../../../../../features/favorites/presentation/widgets/favorite_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharma_now/Cart/presentation/cubits/cart_cubit/cart_cubit.dart';

class MedicineDetailsViewBody extends StatefulWidget {
  const MedicineDetailsViewBody({
    super.key,
    required this.medicineEntity,
  });

  final MedicineEntity medicineEntity;

  @override
  State<MedicineDetailsViewBody> createState() =>
      _MedicineDetailsViewBodyState();
}

class _MedicineDetailsViewBodyState extends State<MedicineDetailsViewBody> {
  int _counter = 1;

  // Convert medicine entity to model for storing in favorites
  Map<String, dynamic> _convertEntityToModel() {
    return {
      'id': widget.medicineEntity.code,
      'name': widget.medicineEntity.name,
      'price': widget.medicineEntity.price,
      'imageUrl': widget.medicineEntity.subabaseORImageUrl,
      'pharmacyName': widget.medicineEntity.pharmacyName,
      'discountRating': widget.medicineEntity.discountRating,
      'isNewProduct': widget.medicineEntity.isNewProduct,
      'description': widget.medicineEntity.description,
    };
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return BlocListener<CartCubit, CartState>(
      listener: (context, state) {
        if (state is CartItemAdded) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Added to cart',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              backgroundColor: const Color.fromARGB(255, 109, 193, 111),
              width: MediaQuery.of(context).size.width * 0.4,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(42),
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

            SizedBox(height: 160.h),
            // Completely Separated Add to Cart Button Section
            _buildAddToCartButton(context),

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
        minHeight: height * 0.6,
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
                  minHeight: 0.65 * height,
                  maxHeight: 0.73 * height,
                ),
                child: Column(
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
                    Text(
                      widget.medicineEntity.pharmcyAddress ?? '',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFF2F4F9),
                            borderRadius: BorderRadius.all(Radius.circular(32)),
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
                                // السعر الأصلي الكلي
                                '${(widget.medicineEntity.price * _counter).toStringAsFixed(0)} EGP',
                                style:
                                    TextStyles.listView_product_name.copyWith(
                                  fontSize: 12.sp,
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                ),
                              ),
                            // Show discounted price or regular price
                            Text(
                              widget.medicineEntity.discountRating > 0
                                  ? '${_calculateDiscountedPrice(widget.medicineEntity.price.toDouble(), widget.medicineEntity.discountRating.toDouble(), _counter).toStringAsFixed(0)} EGP'
                                  : '${(widget.medicineEntity.price * _counter).toStringAsFixed(0)} EGP',
                              style: TextStyle(
                                color: Color(0xFF375DFB),
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      "Description",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Expanded(
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
                : (widget.medicineEntity.discountRating != null &&
                        widget.medicineEntity.discountRating > 0)
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

                        return Image(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: ColorManager.secondaryColor,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => Icon(
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
            context
                .read<CartCubit>()
                .addMedicineToCartWithCount(widget.medicineEntity, _counter);
          },
          child: Text(
            'Add to Cart',
            style: TextStyles.buttonLabel,
          ),
        ),
      ),
    );
  }

  double _calculateDiscountedPrice(
      double originalPrice, double discountPercentage, int quantity) {
    double totalOriginal = originalPrice * quantity;
    double discountAmount = totalOriginal * (discountPercentage / 100);
    double discountedPrice = totalOriginal - discountAmount;
    return discountedPrice;
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
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
