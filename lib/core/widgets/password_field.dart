import 'package:flutter/material.dart';
import 'package:pharma_now/core/widgets/custom_text_field.dart';

import '../utils/app_images.dart';
import '../utils/color_manger.dart';

class PasswordFiled extends StatefulWidget {
  const PasswordFiled({
    super.key,
    required this.lable,
    required this.icon,
    required this.hint,
    this.onSaved,
    required this.textInputType,
    this.validator,
    this.controller,
  });
  final String lable;
  final String icon;
  final String hint;
  final TextInputType textInputType;
  final void Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final TextEditingController? controller;

  @override
  State<PasswordFiled> createState() => _PasswordFiledState();
}

class _PasswordFiledState extends State<PasswordFiled> {
  bool obscureText = true;
  @override
  Widget build(BuildContext context) {
    return CustomTextField(
        obscureText: obscureText,
        textInputType: widget.textInputType,
        onSaved: widget.onSaved,
        controller: widget.controller,
        validator: widget.validator,
        lable: widget.lable,
        icon: widget.icon,
        hint: widget.hint,
        suffixIcon: GestureDetector(
          onTap: () {
            obscureText = !obscureText;
            setState(() {});
          },
          child: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: ColorManager.textInputColor,
          ),
        ));
  }
}
