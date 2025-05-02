import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pharma_now/features/home/presentation/views/main_view.dart';
import 'package:pharma_now/features/home/presentation/views/product_view.dart';
import 'package:pharma_now/features/home/presentation/views/widgets/related_product_list_view_item.dart';

import '../../../../../core/utils/app_images.dart';
import '../../../../../core/utils/button_style.dart';
import '../../../../../core/utils/color_manger.dart';
import '../../../../../core/utils/text_style.dart';

class ProductViewBody extends StatelessWidget {
  const ProductViewBody({super.key, this.isFavorite = false});
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: height * 0.7, // Adjusted height to accommodate button below
            child: Stack(
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
                  height: 0.62 * height,
                  top: 0.009 * height,
                  left: 30,
                  right: 30,
                  child: Material(
                    shadowColor: Color(0xff407BFF).withOpacity(0.24),
                    elevation: 7,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      height: 0.9 * height,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      decoration: BoxDecoration(
                        color: ColorManager.primaryColor,
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 0.21 * height),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Beta Mind",
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600)),
                              GestureDetector(
                                onTap: () {},
                                child: SvgPicture.asset(
                                  isFavorite ? Assets.fav : Assets.nFav,
                                  width: 32.w,
                                  height: 32.h,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            "75ml",
                            style: TextStyle(
                                color: Color(0xff7B7D82),
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          ),
                          // SizedBox(height: 0.02 * height),
                          SizedBox(height: 16.h),
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    color: Color(0xFFF2F4F9),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(32))),
                                child: Row(children: [
                                  IconButton(
                                    onPressed: () {},
                                    icon: Icon(
                                      Icons.remove,
                                      size: 24.sp,
                                    ),
                                  ),
                                  SizedBox(width: 0.05 * width),
                                  Text("1",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20.sp,
                                      )),
                                  SizedBox(width: 0.05 * width),
                                  IconButton(
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.add_circle_outlined,
                                        size: 32.sp,
                                        color: ColorManager.secondaryColor,
                                      ))
                                ]),
                              ),
                              Spacer(),
                              Text("200 LE",
                                  style: TextStyle(
                                      color: Color(0xFF375DFB),
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          Text("Description",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500)),
                          SizedBox(
                            height: 12.h,
                          ),
                          Text(
                            textAlign: TextAlign.left,
                            maxLines: 10,
                            overflow: TextOverflow.ellipsis,
                            "Beta Mine is an innovative product that enhances brain health thanks to its rich ingredients,including Vitamin B6, which supports nerve function and maintains heart health.",
                            style: TextStyle(color: Color(0xffA7AEB5)),
                          )
                        ],
                      ),
                    ),
                  ),
                ),

                // Product image
                Positioned(
                  top: 0.03 * height,
                  left: 0,
                  right: 0,
                  child: Center(
                      child: Image(
                    image: NetworkImage(
                      'https://i.postimg.cc/2yLfw0qy/image-20.png',
                    ),
                  )),
                ),
              ],
            ),
          ),

          // Elevated button now placed under the Stack
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ButtonStyles.primaryButton,
                onPressed: () {
                  // Navigator.pushReplacementNamed(context, HomeView.routeName);
                },
                child: Text(
                  'Add to Cart',
                  style: TextStyles.buttonLabel,
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
