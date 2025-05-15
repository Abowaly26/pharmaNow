import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:pharma_now/features/auth/presentation/views/reset_password_view.dart';
import 'package:pharma_now/core/utils/button_style.dart';
import 'package:pharma_now/core/utils/text_styles.dart';

import '../../../../../core/utils/app_images.dart';
import '../../../../../core/utils/color_manger.dart';

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
  final String _expectedCode = '123456'; // Example of expected code

  // Timer variables
  int _timeLeft = 120; // Two minutes in seconds
  Timer? _timer; // Use nullable Timer instead of initializing with dummy

  String get _formattedTime {
    final minutes = (_timeLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (_timeLeft % 60).toString().padLeft(2, '0');
    return '($minutes:$seconds)';
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

  void _verifyCode() {
    String enteredCode =
        _controllers.map((controller) => controller.text).join();
    if (enteredCode == _expectedCode) {
      // Navigate after successful verification
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => ResetPasswordView(),
        ));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid code. Please try again.')),
      );
      // Reset fields
      for (var controller in _controllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
      setState(() => isCodeComplete = false);
    }
  }

  void _resendCode() {
    // Reset timer
    setState(() {
      _timeLeft = 120;
      _startTimer(); // This will check if timer is active internally
    });

    // Clear current fields
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();

    // Show message to user
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification code has been resent')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 48.h),
        child: Column(children: [
          Align(
            alignment: Alignment.center,
            child: SvgPicture.asset(
              Assets.verification_image,
              width: 280.w,
              height: 290.h,
            ),
          ),
          SizedBox(height: 24.h),

          // Verification title
          Text(
            'Verification Code',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12.h),

          // Instructions text - changed to refer to email instead of phone
          Text(
            'Please enter the 6-digit verification code sent to your email',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.black54,
            ),
          ),

          SizedBox(height: 32.h),

          // Verification code input fields - simplified
          _buildVerificationFields(),

          SizedBox(height: 24.h),

          // Timer and resend section
          _buildTimerAndResendSection(),

          SizedBox(height: 32.h),

          // Confirm button
          ElevatedButton(
            style: ButtonStyles.primaryButton,
            onPressed: isCodeComplete ? _verifyCode : null,
            child: Text(
              'Confirm',
              style: TextStyles.buttonLabel,
            ),
          ),
        ]),
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
          width: 40.w,
          height: 45.h,
          margin: EdgeInsets.symmetric(horizontal: 2.w),
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
                borderRadius: BorderRadius.circular(6.r),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.r),
                borderSide: const BorderSide(
                  color: ColorManager.secondaryColor,
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.r),
                borderSide: const BorderSide(color: Colors.grey, width: 1),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _formattedTime,
          style: const TextStyle(
            color: ColorManager.secondaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: 6.w),
        const Text(
          "Didn't receive the code?",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        TextButton(
          onPressed: _timeLeft > 0 ? null : _resendCode,
          child: Text(
            'Resend',
            style: TextStyle(
              color: _timeLeft > 0 ? Colors.grey : ColorManager.secondaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
