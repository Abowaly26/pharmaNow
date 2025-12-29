import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/core/utils/text_styles.dart';
import 'package:pharma_now/core/widgets/custom_check_box.dart';
import 'package:pharma_now/features/profile/presentation/views/widgets/profile_tab/terms_of_service_view.dart';

class TermsAndConditionsWidget extends StatelessWidget {
  const TermsAndConditionsWidget({
    super.key,
    required this.onChanged,
    required this.value,
  });

  final ValueChanged<bool> onChanged;
  final bool value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomCheckBox(
          isChecked: value,
          onChecked: onChanged,
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'By creating an account, you agree to our ',
                  style: TextStyles.callToActionText.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
                ),
                TextSpan(
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.pushNamed(
                        context,
                        TermsOfServiceView.routeName,
                      );
                    },
                  text: 'Terms and Conditions',
                  style: TextStyles.callToActionSignUP.copyWith(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
