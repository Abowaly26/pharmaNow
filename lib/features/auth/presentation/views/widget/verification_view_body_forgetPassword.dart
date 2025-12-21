import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pharma_now/core/helper_functions/build_error_bar.dart'
    show showCustomBar, MessageType;
import 'package:pharma_now/core/services/get_it_service.dart';
import 'package:pharma_now/core/utils/button_style.dart';
import 'package:pharma_now/core/utils/text_styles.dart';
import 'package:pharma_now/features/auth/domain/repo/auth_repo.dart';

import '../../../../../core/utils/app_images.dart';
import '../../../../../core/utils/color_manger.dart';
import '../reset_password_view.dart';

class VerifiBodyForgetPass extends StatefulWidget {
  const VerifiBodyForgetPass({super.key});

  @override
  State<VerifiBodyForgetPass> createState() => _VerifiBodyForgetPassState();
}

class _VerifiBodyForgetPassState extends State<VerifiBodyForgetPass> {
  final int _codeLength = 6;
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  bool isCodeComplete = false;

  // Timer variables
  int _timeLeft = 120; // Two minutes in seconds
  Timer? _timer; // Use nullable Timer instead of initializing with dummy
  bool _isResending = false;
  bool _isVerifying = false;

  String get _formattedTime {
    final minutes = (_timeLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (_timeLeft % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void initState() {
    super.initState();
    _controllers =
        List.generate(_codeLength, (index) => TextEditingController());
    _focusNodes = List.generate(_codeLength, (index) => FocusNode());
    _startTimer();
  }

  void _startTimer() {
    if (_timer != null && _timer!.isActive) return; // Prevent multiple timers
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    // Release resources
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _timer?.cancel(); // Safely cancel the timer
    super.dispose();
  }

  Future<void> _resendCode() async {
    // In a real implementation, you would call your backend to resend the code
    // For now, we'll just reset the timer and clear the fields
    
    setState(() {
      _timeLeft = 120;
      _startTimer(); // This will check if timer is active internally
      _isResending = true;
    });

    // Clear current fields
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();

    // Show success message to user
    showCustomBar(
      context,
      'Password reset link resent! Check your email or spam folder.',
      type: MessageType.success,
    );
    
    setState(() => _isResending = false);
  }

  void _verifyCode() {
    String enteredCode =
        _controllers.map((controller) => controller.text).join();
    
    // In a real app, you would verify this code with your backend
    // For demo purposes, we'll accept any 6-digit code
    if (enteredCode.length == 6 && RegExp(r'^[0-9]+$').hasMatch(enteredCode)) {
      setState(() => _isVerifying = true);
      
      // Simulate verification process
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() => _isVerifying = false);
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => const ResetPasswordView(),
          ));
        }
      });
    } else {
      showCustomBar(
        context,
        'Please enter a valid 6-digit code',
        type: MessageType.error,
      );
      
      // Reset fields
      for (var controller in _controllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
      setState(() => isCodeComplete = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 48.h),
        child: Column(
          children: [
            Align(
              alignment: Alignment.center,
              child: SvgPicture.asset(
                Assets.verification_image,
                width: 280.w,
                height: 290.h,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Check Your Email',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'We have sent a password reset link to your email address. Please open your email and tap the reset link.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
            SizedBox(height: 32.h),
            _buildVerificationFields(),
            SizedBox(height: 24.h),
            _buildTimerAndResendSection(),
            SizedBox(height: 32.h),
            ElevatedButton(
              style: ButtonStyles.primaryButton,
              onPressed: _isVerifying ? null : _verifyCode,
              child: _isVerifying
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(
                      'Continue',
                      style: TextStyles.buttonLabel,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Extract verification fields building logic to a separate method for simplification
  Widget _buildVerificationFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _codeLength,
        (index) => Container(
          width: 50.w,
          height: 50.h,
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(1),
            ],
            onChanged: (value) {
              _handleFieldChange(value, index);
            },
            decoration: InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(vertical: 0.h, horizontal: 0.w),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(
                  color: Colors.grey,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(
                  color: ColorManager.secondaryColor,
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(
                  color: Colors.grey,
                  width: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Extract field change handling logic to a separate method
  void _handleFieldChange(String value, int index) {
    if (value.isNotEmpty && index < _codeLength - 1) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }

    // Check if all fields are filled
    setState(() {
      isCodeComplete = _controllers.every((c) => c.text.isNotEmpty);
    });
  }

  // Extract timer and resend section building logic to a separate method
  Widget _buildTimerAndResendSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: ColorManager.buttom_info,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: ColorManager.colorLines),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Didn't receive the email?",
                      style: TextStyles.sectionTitle,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _timeLeft > 0
                          ? ''
                          : 'Request a new password reset link',
                      style: TextStyles.callToActionText,
                    ),
                    if (_timeLeft > 0)
                      RichText(
                        text: TextSpan(
                          style: TextStyles.callToActionText,
                          children: [
                            const TextSpan(text: 'Resend available in   '),
                            TextSpan(
                              text: _formattedTime,
                              style: TextStyles.callToActionText.copyWith(
                                color: ColorManager.secondaryColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              SizedBox(
                width: 110.w,
                height: 36.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorManager.secondaryColor,
                    disabledBackgroundColor:
                        ColorManager.lightPurpleColorF5,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r)),
                  ),
                  onPressed: (_isResending || _timeLeft > 0)
                      ? null
                      : _resendCode,
                  child: _isResending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child:
                              CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          'Resend',
                          style: TextStyles.buttonLabel,
                        ),
                ),
              ),
            ],
          ),
          if (_timeLeft > 0) ...[
            SizedBox(height: 10.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(100.r),
              child: LinearProgressIndicator(
                minHeight: 6.h,
                value: 120 == 0
                    ? 0
                    : 1 -
                        (_timeLeft /
                            120),
                backgroundColor: Colors.white,
                valueColor: const AlwaysStoppedAnimation<Color>(
                    ColorManager.secondaryColor),
              ),
            ),
          ],
        ],
      ),
    );
  }
}