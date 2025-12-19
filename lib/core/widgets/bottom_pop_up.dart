import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pharma_now/core/utils/app_images.dart';
import 'package:pharma_now/core/utils/button_style.dart';
import 'package:pharma_now/core/utils/color_manger.dart';
import 'package:pharma_now/core/utils/text_styles.dart';

void showSuccessBottomSheet(
  BuildContext context,
  String? text,
  void Function()? onPressed,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    isDismissible: true,
    builder: (BuildContext context) {
      // Get the screen width
      final screenWidth = MediaQuery.of(context).size.width;

      return Container(
        width: screenWidth,
        padding: EdgeInsets.zero,
        margin: EdgeInsets.zero,
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success popup container
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                // White container
                Container(
                  width: screenWidth,
                  margin: const EdgeInsets.only(top: 35),
                  padding: const EdgeInsets.only(top: 55, bottom: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Success Title
                      Text(
                        'Success',
                        style: TextStyles.mainTextOfPopUp,
                      ),
                      const SizedBox(height: 12),

                      // Success Message
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          text!,
                          textAlign: TextAlign.center,
                          style: TextStyles.secdaryTextOfPopUp,
                        ),
                      ),
                      SizedBox(height: 25.h),

                      // OK Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: ElevatedButton(
                          style: ButtonStyles.primaryButton,
                          onPressed: () {
                            // Close the bottom sheet first
                            Navigator.of(context).pop();
                            // Then execute the provided action (e.g., navigation)
                            if (onPressed != null) {
                              onPressed();
                            }
                          },
                          child: Text(
                            'Ok',
                            style: TextStyles.buttonLabel,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Success Icon that overlaps the top edge
                Positioned(
                  top: 0,
                  child: Container(
                    width: 91,
                    height: 91,
                    decoration: BoxDecoration(
                      color: ColorManager.secondaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        Assets.badgeCheck,
                        width: 38.25,
                        height: 38.25,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
