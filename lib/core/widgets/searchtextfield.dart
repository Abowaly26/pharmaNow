import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pharma_now/core/utils/color_manger.dart';
import '../../features/search/presentation/cubit/cubit/search_cubit.dart';
import '../utils/app_images.dart';

class Searchtextfield extends StatefulWidget {
  final bool readOnly;
  final VoidCallback? onTap;
  final String? initialValue;
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final Function(String)? onSubmitted;

  const Searchtextfield({
    super.key,
    this.readOnly = false,
    this.onTap,
    this.initialValue,
    this.focusNode,
    this.controller,
    this.onSubmitted,
  });

  @override
  State<Searchtextfield> createState() => _SearchtextfieldState();
}

class _SearchtextfieldState extends State<Searchtextfield> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ?? TextEditingController(text: widget.initialValue);
    _focusNode = widget.focusNode ?? FocusNode();

    if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!widget.readOnly) {
          context
              .read<SearchCubit>()
              .searchProducts(query: widget.initialValue!);
        }
      });
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: Color(0xffF2F4F9), // Light gray background color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r), // Rounded corners
        ),
      ),
      child: TextFormField(
        controller: _controller,
        focusNode: _focusNode,
        readOnly: widget.readOnly,
        onTap: widget.onTap,
        onChanged: (query) {
          if (!widget.readOnly) {
            context.read<SearchCubit>().searchProducts(query: query);
          }
        },
        onFieldSubmitted: widget.onSubmitted,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          filled: true,
          fillColor: Color(0xffF2F4F9), // Light gray background color
          hintText: 'Search ...', // Updated hint text
          hintStyle: TextStyle(
            fontSize: 16.sp,
            color: ColorManager.colorOfsecondPopUp,
            fontWeight: FontWeight.w400,
          ),
          contentPadding:
              EdgeInsets.symmetric(vertical: 12.h), // Adjust vertical padding
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24.r),
            borderSide: BorderSide.none, // No border
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24.r),
            borderSide: BorderSide.none, // No border
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24.r),
            borderSide: BorderSide.none, // No border
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Icon(
              Icons.search,
              color: ColorManager.colorOfsecondPopUp,
              size: 24.sp,
            ),
          ),
          // Settings/filter icon on the right
          suffixIcon: Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: Icon(
              Icons.tune,
              color: Colors.grey.shade400,
              size: 24.sp,
            ),
          ),
        ),
      ),
    );
  }
}
