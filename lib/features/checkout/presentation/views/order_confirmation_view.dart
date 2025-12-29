import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pharma_now/core/utils/color_manger.dart';
import 'package:pharma_now/core/helper_functions/show_custom_bar.dart';
import 'package:pharma_now/core/widgets/custom_app_bar.dart';
import 'dart:ui';

class OrderConfirmationView extends StatefulWidget {
  static const routeName = 'order_confirmation';
  final Map<String, dynamic> orderData;

  const OrderConfirmationView({super.key, required this.orderData});

  @override
  State<OrderConfirmationView> createState() => _OrderConfirmationViewState();
}

class _OrderConfirmationViewState extends State<OrderConfirmationView> {
  String? selectedImagePath;
  File? paymentProofFile;
  bool _isPickingImage = false;
  bool _isProcessing = false;

  Future<void> _pickPaymentProof() async {
    if (_isPickingImage) return;

    setState(() => _isPickingImage = true);

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image != null) {
        setState(() {
          selectedImagePath = image.path;
          paymentProofFile = File(image.path);
        });
      }
    } finally {
      setState(() => _isPickingImage = false);
    }
  }

  void _showFullScreenImage() {
    if (selectedImagePath == null) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.file(
                  File(selectedImagePath!),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 40.h,
              right: 20.w,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: Colors.white, size: 28.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool needsProof = widget.orderData['needsProof'] ?? false;
    final double subtotal = widget.orderData['subtotal'] ?? 0;
    final double delivery = widget.orderData['delivery'] ?? 0;
    final double total = widget.orderData['total'] ?? 0;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(48.sp),
            child: PharmaAppBar(
              title: 'Order Confirmation',
              isBack: !_isProcessing,
              onPressed: _isProcessing
                  ? null
                  : () {
                      SystemChannels.textInput.invokeMethod('TextInput.hide');
                      FocusScope.of(context).requestFocus(FocusNode());
                      Navigator.pop(context);
                    },
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Delivery & Payment'),
                      SizedBox(height: 16.h),
                      _buildDetailsCard(),
                      if (needsProof) ...[
                        SizedBox(height: 28.h),
                        _buildSectionTitle('Payment Instructions'),
                        SizedBox(height: 16.h),
                        _buildPaymentInstructionCard(),
                        SizedBox(height: 28.h),
                        _buildSectionTitle('Upload Proof'),
                        SizedBox(height: 16.h),
                        _buildUploadProofArea(),
                      ],
                      SizedBox(height: 28.h),
                      _buildSectionTitle('Order Summary'),
                      SizedBox(height: 16.h),
                      _buildSummaryCard(subtotal, delivery, total),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),
              _buildBottomActionButton(needsProof),
            ],
          ),
        ),
        if (_isProcessing)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(
                color: Colors.black.withOpacity(0.12),
                child: Center(
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.r),
                    elevation: 10,
                    child: Container(
                      width: 280.w,
                      padding: EdgeInsets.symmetric(
                          vertical: 32.h, horizontal: 24.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                height: 64.h,
                                width: 64.h,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    ColorManager.secondaryColor
                                        .withOpacity(0.2),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 64.h,
                                width: 64.h,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      ColorManager.secondaryColor),
                                ),
                              ),
                              Icon(
                                Icons.shopping_cart_outlined,
                                color: ColorManager.secondaryColor,
                                size: 24.sp,
                              ),
                            ],
                          ),
                          SizedBox(height: 24.h),
                          Text(
                            'Processing Order',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              letterSpacing: 0.5,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'Securely verifying your details and placing your order...',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.sp,
                              height: 1.5,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w400,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.lock_outline,
                                    size: 14.sp, color: Colors.grey[400]),
                                SizedBox(width: 6.w),
                                Text(
                                  'Secure Checkout',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: Colors.grey[400],
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 3.w,
          height: 14.h,
          decoration: BoxDecoration(
            color: ColorManager.secondaryColor,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF2D3142),
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey[200]!.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDetailItem(
              Icons.person_outline, 'Recipient', widget.orderData['name']),
          _buildDivider(),
          _buildDetailItem(
              Icons.phone_android_outlined, 'Phone', widget.orderData['phone']),
          _buildDivider(),
          _buildDetailItem(Icons.location_on_outlined, 'Address',
              widget.orderData['address']),
          _buildDivider(),
          _buildDetailItem(
            Icons.payment_outlined,
            'Payment Method',
            widget.orderData['senderPhone'] != null
                ? '${widget.orderData['paymentMethod']} (${widget.orderData['senderPhone']})'
                : widget.orderData['paymentMethod'],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 36.h,
            width: 36.h,
            decoration: BoxDecoration(
              color: ColorManager.secondaryColor.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: ColorManager.secondaryColor, size: 18.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 10.sp,
                        color: const Color(0xFF9EA5B1),
                        fontWeight: FontWeight.w600)),
                SizedBox(height: 2.h),
                Text(value,
                    style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1D23))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() => Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child:
            Divider(height: 1, color: const Color(0xFFF1F4F9), thickness: 0.8),
      );

  Widget _buildPaymentInstructionCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [ColorManager.secondaryColor.withOpacity(0.05), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: ColorManager.secondaryColor.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Transfer to Account:',
                      style:
                          TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
                  SizedBox(height: 4.h),
                  Text(
                    widget.orderData['walletNumber'] ?? '',
                    style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        letterSpacing: 1.2),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(
                      ClipboardData(text: widget.orderData['walletNumber']));
                  showCustomBar(context, 'Number copied!',
                      type: MessageType.success);
                },
                icon: Icon(Icons.copy_rounded, size: 16.sp),
                label: const Text('Copy'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorManager.secondaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r)),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: Colors.amber[800], size: 20.sp),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'Please transfer the exact amount and upload the screenshot.',
                    style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.amber[900],
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadProofArea() {
    return GestureDetector(
      onTap: _pickPaymentProof,
      child: Container(
        width: double.infinity,
        height: 180.h,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFD),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selectedImagePath != null
                ? ColorManager.secondaryColor
                : const Color(0xFFE5E9F2),
            width: 1.5,
          ),
        ),
        child: selectedImagePath != null
            ? Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.r),
                      child: Container(
                        color: Colors.grey[100],
                        child: GestureDetector(
                          onTap: _showFullScreenImage,
                          child: Image.file(
                            File(selectedImagePath!),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12.h,
                    right: 12.w,
                    child: GestureDetector(
                      onTap: _pickPaymentProof,
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            shape: BoxShape.circle),
                        child:
                            Icon(Icons.edit, color: Colors.white, size: 16.sp),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _showFullScreenImage,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.35),
                          borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(20.r)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.fullscreen,
                                color: Colors.white, size: 14.sp),
                            SizedBox(width: 6.w),
                            Text(
                              'Full Preview',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: ColorManager.secondaryColor.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.cloud_upload_outlined,
                        color: ColorManager.secondaryColor, size: 32.sp),
                  ),
                  SizedBox(height: 12.h),
                  Text('Tap to upload payment proof',
                      style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2D3142))),
                  SizedBox(height: 4.h),
                  Text('JPEG, PNG, or Screenshot',
                      style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF9EA5B1),
                          fontWeight: FontWeight.w500)),
                ],
              ),
      ),
    );
  }

  Widget _buildSummaryCard(double subtotal, double delivery, double total) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFF1F4F9)),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Subtotal', subtotal, isTotal: false),
          SizedBox(height: 12.h),
          _buildSummaryRow('Delivery Fee', delivery, isTotal: false),
          SizedBox(height: 20.h),
          Row(
            children: List.generate(
              20,
              (index) => Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  child: Container(height: 1, color: const Color(0xFFE5E9F2)),
                ),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Payable Amount',
                  style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2D3142))),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${total.toStringAsFixed(0)} EGP',
                      style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w900,
                          color: ColorManager.secondaryColor)),
                  Text('VAT Included',
                      style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF9EA5B1))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount,
      {required bool isTotal}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B))),
        Text('${amount.toStringAsFixed(0)} EGP',
            style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B))),
      ],
    );
  }

  Widget _buildBottomActionButton(bool needsProof) {
    bool canProceed = !needsProof || selectedImagePath != null;

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 60.h,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18.r),
              gradient: LinearGradient(
                colors: [
                  ColorManager.secondaryColor,
                  ColorManager.secondaryColor.withBlue(220),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: ColorManager.secondaryColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: canProceed ? _confirmOrder : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                disabledBackgroundColor: Colors.grey[300],
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.r)),
              ),
              child: _isProcessing
                  ? SizedBox(
                      height: 24.h,
                      width: 24.h,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      'Confirm & Place Order',
                      style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmOrder() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() => _isProcessing = true);
    // Return the picked file to the caller (CheckoutViewBody)
    Future.delayed(const Duration(milliseconds: 100), () {
      Navigator.pop(context, paymentProofFile ?? true);
    });
  }
}
