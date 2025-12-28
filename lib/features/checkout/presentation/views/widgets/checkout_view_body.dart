import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:ui';
import 'package:pharma_now/core/utils/color_manger.dart';
import 'package:pharma_now/core/utils/text_styles.dart';
import 'package:pharma_now/core/helper_functions/build_error_bar.dart';
import 'package:pharma_now/core/widgets/bottom_pop_up.dart';
import 'package:pharma_now/features/checkout/data/services/order_service.dart';
import 'package:pharma_now/features/checkout/domain/entites/shipingadressentity.dart';
import 'package:pharma_now/features/checkout/presentation/views/widgets/checkout_steps.dart';
import 'package:pharma_now/features/checkout/presentation/views/order_confirmation_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharma_now/features/order/presentation/cubits/cart_cubit/cart_cubit.dart';
import 'package:pharma_now/features/home/presentation/ui_model/entities/cart_entity.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:pharma_now/features/profile/presentation/providers/profile_provider.dart';
import 'package:pharma_now/core/services/supabase_storage.dart';

class CheckoutViewBody extends StatefulWidget {
  final Function(bool) onProcessingChanged;
  const CheckoutViewBody({super.key, required this.onProcessingChanged});

  @override
  State<CheckoutViewBody> createState() => _CheckoutViewBodyState();
}

class _CheckoutViewBodyState extends State<CheckoutViewBody>
    with TickerProviderStateMixin {
  late PageController pageController;
  late AnimationController _animationController;

  // Form data
  int selectedShipping = -1;
  final addressFormKey = GlobalKey<FormState>();
  String fullName = '';
  String email = '';
  String address = '';
  String city = '';
  String apartment = '';
  String phone = '';
  int selectedPayment = -1;
  int currentPage = 0;

  // Wallet phone number and Payment Proof
  String walletPhone = '';
  final walletPhoneController = TextEditingController();
  String? paymentProofUrl;
  String? selectedImagePath; // To show preview
  bool isUploadingImage = false;
  File? paymentProofFile;
  bool _isPickerActive = false;

  // Dynamic shipping options
  final List<String> shippingTitles = [
    'Express Delivery',
    'Standard Delivery',
  ];
  final List<String> shippingSubtitles = [
    'Receive your order within 2 days',
    'Receive your order within 3-5 days',
  ];
  final List<double> shippingPrices = [50, 30];
  final List<IconData> shippingIcons = [
    Icons.local_shipping,
    Icons.local_shipping_outlined,
  ];

  // Payment options - showing our wallet numbers
  final List<Map<String, dynamic>> paymentOptions = [
    {
      'title': 'Cash on Delivery',
      'subtitle': 'Pay when you receive your order',
      'icon': Icons.money,
      'showWalletNumber': false,
    },
    {
      'title': 'Vodafone Cash',
      'subtitle': 'Transfer to: 01012345678',
      'icon': Icons.phone_android,
      'showWalletNumber': true,
      'walletNumber': '01012345678',
      'requiresInput': true,
      'hint': 'Enter your Vodafone Cash number',
    },
    {
      'title': 'InstaPay',
      'subtitle': 'Transfer to: 01098765432',
      'icon': Icons.account_balance_wallet,
      'showWalletNumber': true,
      'walletNumber': '01098765432',
      'requiresInput': true,
      'hint': 'Enter your InstaPay account number/phone',
    },
  ];

  // Text Controllers for address fields
  late TextEditingController fullNameController;
  late TextEditingController emailController;
  late TextEditingController addressController;
  late TextEditingController cityController;
  late TextEditingController apartmentController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    // Initialize text controllers with user data if available
    final user = context.read<ProfileProvider>().currentUser;
    fullNameController = TextEditingController(text: user?.name ?? '');
    emailController = TextEditingController(text: user?.email ?? '');
    addressController = TextEditingController();
    cityController = TextEditingController();
    apartmentController = TextEditingController();
    phoneController = TextEditingController();

    // Sync initial values with state variables
    fullName = fullNameController.text;
    email = emailController.text;

    // Initialize variables
    paymentProofFile = null;

    pageController.addListener(() {
      setState(() {
        currentPage = pageController.page!.toInt();
      });
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    _animationController.dispose();

    // Dispose text controllers
    fullNameController.dispose();
    emailController.dispose();
    addressController.dispose();
    cityController.dispose();
    apartmentController.dispose();
    phoneController.dispose();
    walletPhoneController.dispose();

    super.dispose();
  }

  Future<void> _pickPaymentProof() async {
    if (_isPickerActive) return;
    _isPickerActive = true;
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          paymentProofFile = File(pickedFile.path);
          selectedImagePath = pickedFile.path;
        });
      }
    } finally {
      _isPickerActive = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final cartEntity = (state as dynamic).cartEntity as CartEntity;
        double subtotal = cartEntity.calculateTotalPrice();
        double delivery =
            selectedShipping >= 0 ? shippingPrices[selectedShipping] : 0;
        double total = subtotal + delivery;
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
            ),
            child: Column(
              children: [
                // Header with progress
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CheckoutSteps(
                    currentPage: currentPage,
                    pageController: pageController,
                  ),
                ),
                // Main content
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: PageView.builder(
                        controller: pageController,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: 3,
                        itemBuilder: (context, index) {
                          return _buildPageContent(
                              index, subtotal, delivery, total);
                        },
                      ),
                    ),
                  ),
                ),
                // Bottom section with button
                Container(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 20,
                        offset: Offset(0, -5),
                      ),
                    ],
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24.r),
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildActionButton(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPageContent(
      int index, double subtotal, double delivery, double total) {
    switch (index) {
      case 0:
        return _buildShippingPage();
      case 1:
        return _buildAddressPage();
      case 2:
        return _buildPaymentPage();
      default:
        return Container();
    }
  }

  Widget _buildShippingPage() {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Delivery Method',
              style: TextStyles.bold24Black,
            ),
            SizedBox(height: 8.h),
            Text(
              'Select how you\'d like to receive your order',
              style: TextStyles.settingItemSubTitle,
            ),
            SizedBox(height: 24.h),
            ...List.generate(
                shippingTitles.length,
                (i) => Column(
                      children: [
                        _buildModernShippingOption(
                          shippingTitles[i],
                          shippingSubtitles[i],
                          shippingPrices[i].toStringAsFixed(0),
                          shippingIcons[i],
                          i,
                        ),
                        if (i != shippingTitles.length - 1)
                          SizedBox(height: 12.h),
                      ],
                    )),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressPage() {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Form(
        key: addressFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delivery Address',
              style: TextStyles.bold24Black,
            ),
            SizedBox(height: 8.h),
            Text(
              'Where should we deliver your order?',
              style: TextStyles.settingItemSubTitle,
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  children: [
                    _buildModernTextField(
                      'Full Name',
                      Icons.person_outline,
                      TextInputType.name,
                      fullNameController,
                      (v) => fullName = v,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your full name';
                        }
                        if (value.length < 3) {
                          return 'Name is too short';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 14.h),
                    _buildModernTextField(
                      'Email Address',
                      Icons.email_outlined,
                      TextInputType.emailAddress,
                      emailController,
                      (v) => email = v,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        final emailRegex =
                            RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        if (!emailRegex.hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 14.h),
                    _buildModernTextField(
                      'Street Address',
                      Icons.location_on_outlined,
                      TextInputType.streetAddress,
                      addressController,
                      (v) => address = v,
                      textInputAction: TextInputAction.next,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Address is required' : null,
                    ),
                    SizedBox(height: 14.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildModernTextField(
                            'City',
                            Icons.location_city_outlined,
                            TextInputType.text,
                            cityController,
                            (v) => city = v,
                            textInputAction: TextInputAction.next,
                            validator: (v) => v == null || v.isEmpty
                                ? 'City is required'
                                : null,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _buildModernTextField(
                            'Apartment',
                            Icons.home_outlined,
                            TextInputType.text,
                            apartmentController,
                            (v) => apartment = v,
                            textInputAction: TextInputAction.next,
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    _buildModernTextField(
                      'Phone Number',
                      Icons.phone_outlined,
                      TextInputType.phone,
                      phoneController,
                      (v) => phone = v,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        if (value.length != 11) {
                          return 'Phone number must be 11 digits';
                        }
                        if (!value.startsWith('01')) {
                          return 'Invalid Egyptian phone number';
                        }
                        return null;
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(11),
                      ],
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentPage() {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Method',
              style: TextStyles.bold24Black,
            ),
            SizedBox(height: 8.h),
            Text(
              'Choose your preferred payment method',
              style: TextStyles.settingItemSubTitle,
            ),
            SizedBox(height: 24.h),
            ...List.generate(
              paymentOptions.length,
              (i) => Column(
                children: [
                  _buildModernPaymentOption(
                    paymentOptions[i]['title'],
                    paymentOptions[i]['icon'],
                    i,
                    requiresInput: paymentOptions[i]['requiresInput'] ?? false,
                    hint: paymentOptions[i]['hint'],
                  ),
                  if (i != paymentOptions.length - 1) SizedBox(height: 12.h),
                ],
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildModernShippingOption(
    String title,
    String subtitle,
    String price,
    IconData icon,
    int index,
  ) {
    bool isSelected = selectedShipping == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedShipping = index;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected
              ? ColorManager.secondaryColor.withOpacity(0.08)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? ColorManager.secondaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color:
                    isSelected ? ColorManager.secondaryColor : Colors.grey[400],
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 22.sp,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyles.settingItemTitle,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyles.settingItemSubTitle,
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? ColorManager.secondaryColor.withOpacity(0.15)
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                '$price EGP',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? ColorManager.secondaryColor
                      : Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTextField(
    String hint,
    IconData icon,
    TextInputType inputType,
    TextEditingController controller,
    Function(String) onChanged, {
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    TextInputAction textInputAction = TextInputAction.next,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      onChanged: onChanged,
      validator: validator,
      inputFormatters: inputFormatters,
      textInputAction: textInputAction,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: TextStyle(
        fontSize: 14.sp,
        color: ColorManager.blackColor,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey[600], size: 20.sp),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        hintStyle: TextStyle(
          color: Colors.grey[400],
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide:
              BorderSide(color: ColorManager.secondaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.red.shade300, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.red, width: 1.5),
        ),
        errorStyle: TextStyle(
          color: Colors.red,
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildModernPaymentOption(
    String title,
    IconData icon,
    int index, {
    bool requiresInput = false,
    String? hint,
  }) {
    bool isSelected = selectedPayment == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPayment = index;
          if (!requiresInput) {
            walletPhone = '';
            walletPhoneController.clear();
          }
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected
              ? ColorManager.secondaryColor.withOpacity(0.08)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? ColorManager.secondaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? ColorManager.secondaryColor
                        : Colors.grey[400],
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 22.sp,
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyles.settingItemTitle,
                      ),
                      Text(
                        paymentOptions[index]['subtitle'] ?? '',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: ColorManager.secondaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14.sp,
                    ),
                  ),
              ],
            ),
            // Phone number input for wallet options
            if (isSelected && requiresInput) ...[
              SizedBox(height: 12.h),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextFormField(
                  controller: walletPhoneController,
                  keyboardType: TextInputType.phone,
                  onChanged: (v) {
                    walletPhone = v;
                  },
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: ColorManager.blackColor,
                  ),
                  decoration: InputDecoration(
                    hintText: hint ?? 'Enter phone number',
                    prefixIcon:
                        Icon(Icons.phone, color: Colors.grey[600], size: 18.sp),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                    hintStyle:
                        TextStyle(color: Colors.grey[500], fontSize: 13.sp),
                    errorStyle: TextStyle(fontSize: 10.sp),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    if (value.length != 11) {
                      return 'Invalid';
                    }
                    return null;
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return Container(
      width: double.infinity,
      height: 54.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: ColorManager.secondaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _handleNextStep,
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorManager.secondaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: Row(
            key: ValueKey<int>(currentPage),
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _getButtonText(),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(width: 10.w),
              Icon(Icons.arrow_forward_rounded, size: 20.sp),
            ],
          ),
        ),
      ),
    );
  }

  String _getButtonText() {
    switch (currentPage) {
      case 0:
        return 'Continue to Address';
      case 1:
        return 'Continue to Payment';
      case 2:
        return 'Review Order';
      default:
        return 'Next';
    }
  }

  void _handleNextStep() {
    // Calculate totals for navigation to confirmation screen
    final cartState = context.read<CartCubit>().state;
    final cartEntity = (cartState as dynamic).cartEntity as CartEntity;
    double subtotal = cartEntity.calculateTotalPrice();
    double delivery =
        selectedShipping >= 0 ? shippingPrices[selectedShipping] : 0;
    double total = subtotal + delivery;

    if (currentPage == 0) {
      if (selectedShipping == -1) {
        showCustomBar(context, 'Please select a delivery method',
            type: MessageType.warning);
        return;
      }
      _goToNextPage();
    } else if (currentPage == 1) {
      if (!addressFormKey.currentState!.validate()) {
        return;
      }

      // Update field values
      fullName = fullNameController.text.trim();
      email = emailController.text.trim();
      address = addressController.text.trim();
      city = cityController.text.trim();
      apartment = apartmentController.text.trim();
      phone = phoneController.text.trim();

      _goToNextPage();
    } else if (currentPage == 2) {
      if (selectedPayment == -1) {
        showCustomBar(context, 'Please select a payment method',
            type: MessageType.warning);
        return;
      }

      // Check if wallet payment requires phone number
      if (paymentOptions[selectedPayment]['requiresInput'] == true &&
          walletPhone.trim().isEmpty) {
        showCustomBar(context, 'Please enter your wallet phone number',
            type: MessageType.warning);
        return;
      }

      // Navigate to full-screen confirmation instead of bottom sheet
      bool needsProof = selectedPayment >= 0 &&
          paymentOptions[selectedPayment]['requiresInput'] == true;

      Navigator.pushNamed(
        context,
        OrderConfirmationView.routeName,
        arguments: {
          'name': fullName,
          'phone': phone,
          'address':
              '$address, $city${apartment.isNotEmpty ? ', $apartment' : ''}',
          'paymentMethod': paymentOptions[selectedPayment]['title'],
          'senderPhone': walletPhone.isNotEmpty ? walletPhone : phone,
          'walletNumber': paymentOptions[selectedPayment]['walletNumber'],
          'needsProof': needsProof,
          'subtotal': subtotal,
          'delivery': delivery,
          'total': total,
        },
      ).then((value) {
        if (value != null) {
          if (value is File) {
            paymentProofFile = value;
            selectedImagePath = value.path;
          }
          _completeOrder();
        }
      });
    }
  }

  void _goToNextPage() {
    pageController.animateToPage(
      currentPage + 1,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _completeOrder() async {
    widget.onProcessingChanged(true);

    try {
      // 1. Check if we need to upload payment proof first
      String? uploadedProofUrl;
      final needsProof = selectedPayment >= 0 &&
          paymentOptions[selectedPayment]['requiresInput'] == true;

      if (needsProof) {
        if (paymentProofFile == null) {
          // This should be caught by validation before calling this method,
          // but good as a safety check
          Navigator.of(context).pop();
          showCustomBar(
            context,
            'Please upload your payment proof',
            type: MessageType.warning,
          );
          return;
        }

        // Get user ID
        final user = context.read<ProfileProvider>().currentUser;
        if (user == null) {
          throw Exception('User authentication required');
        }

        // Upload proof
        // Note: You need to ensure SupabaseStorageService.uploadPaymentProof exists
        // as implemented in the previous step
        final supabaseService = GetIt.I<SupabaseStorageService>();
        uploadedProofUrl = await supabaseService.uploadPaymentProof(
            paymentProofFile!, user.uId); // Assuming uId is the field name
      }

      // 2. Get cart data
      final cartState = context.read<CartCubit>().state;
      final cartEntity = (cartState as dynamic).cartEntity as CartEntity;

      // 3. Calculate totals
      double subtotal = cartEntity.calculateTotalPrice();
      double delivery =
          selectedShipping >= 0 ? shippingPrices[selectedShipping] : 0;
      double total = subtotal + delivery;

      // 4. Create shipping address entity
      final shippingAddress = ShippingAddressEntity(
        namee: fullName,
        email: email,
        address: address,
        city: city,
        apartmentNumber: apartment,
        phoneNumber: phone,
      );

      // 5. Get order service
      final orderService = GetIt.I<OrderService>();

      // 6. Create order in Firebase
      final orderId = await orderService.createOrderFromCart(
        cartItems: cartEntity.cartItems,
        payWithCash: selectedPayment == 0, // Cash on Delivery
        shippingAddress: shippingAddress,
        subtotal: subtotal,
        deliveryFee: delivery,
        totalAmount: total,
        paymentProofUrl: uploadedProofUrl,
        paymentMethodName: paymentOptions[selectedPayment]['title'],
        senderWalletPhone: walletPhone.isNotEmpty ? walletPhone : phone,
        pharmacyWalletNumber: paymentOptions[selectedPayment]['walletNumber'],
      );

      // 7. Clear the cart cubit
      context.read<CartCubit>().clearCart();

      // 8. Stop processing state
      widget.onProcessingChanged(false);

      // 9. Show success bottom sheet
      showSuccessBottomSheet(
        context,
        'Your order #$orderId has been placed successfully!\n\nWe\'ll send you a confirmation shortly.',
        () {
          Navigator.of(context).pushNamedAndRemoveUntil(
            'MyHomePage',
            (route) => false,
          );
        },
        isDismissible: false,
        enableDrag: false,
        buttonText: 'Continue Shopping',
      );
    } catch (e) {
      // Stop processing state
      widget.onProcessingChanged(false);

      // Show error snackbar
      String errorMessage = 'Failed to create order. Please try again.';
      if (e.toString().contains('User authentication')) {
        errorMessage = 'Please sign in to place an order';
      } else {
        // Pass the actual error message for diagnostics on real device
        errorMessage = e.toString().replaceAll('Exception:', '').trim();
      }

      showCustomBar(
        context,
        errorMessage,
        type: MessageType.error,
      );
      print('Order Error: $e');
    }
  }
}
