import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:pharma_now/core/utils/color_manger.dart';
import 'package:pharma_now/core/utils/text_styles.dart';
import 'package:pharma_now/core/helper_functions/build_error_bar.dart';
import 'package:pharma_now/core/widgets/bottom_pop_up.dart';
import 'package:pharma_now/features/checkout/data/services/order_service.dart';
import 'package:pharma_now/features/checkout/domain/entites/shipingadressentity.dart';
import 'package:pharma_now/features/checkout/presentation/views/widgets/checkout_steps.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharma_now/features/order/presentation/cubits/cart_cubit/cart_cubit.dart';
import 'package:pharma_now/features/home/presentation/ui_model/entities/cart_entity.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:pharma_now/features/profile/presentation/providers/profile_provider.dart';

class CheckoutViewBody extends StatefulWidget {
  const CheckoutViewBody({super.key});

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
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        paymentProofFile = File(pickedFile.path);
        selectedImagePath = pickedFile.path;
      });
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
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 4.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (currentPage == 2)
                          _buildPaymentSummary(subtotal, delivery, total),
                        if (currentPage == 2) SizedBox(height: 12.h),
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
              if (paymentOptions[index]['showWalletNumber'] == true) ...[
                // Vodafone Cash or InstaPay Professional Card
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: ColorManager.secondaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Transfer to Account:',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                paymentOptions[index]['walletNumber'],
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: ColorManager.blackColor,
                                  letterSpacing: 1.2,
                                  fontFamily: 'Courier', // Professional look
                                ),
                              ),
                            ],
                          ),
                          Material(
                            color: ColorManager.secondaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8.r),
                              onTap: () {
                                Clipboard.setData(ClipboardData(
                                    text: paymentOptions[index]
                                        ['walletNumber']));
                                showCustomBar(
                                  context,
                                  'Number copied to clipboard!',
                                  type: MessageType.success,
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.all(8.w),
                                child: Icon(
                                  Icons.copy_rounded,
                                  color: ColorManager.secondaryColor,
                                  size: 20.sp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: ColorManager.secondaryColor,
                                size: 16.sp),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                'Step 1: Transfer total amount to this number.\nStep 2: Take a screenshot and upload it below.',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.grey[700],
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'Upload Payment Proof',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: ColorManager.blackColor,
                  ),
                ),
                SizedBox(height: 10.h),
                GestureDetector(
                  onTap: _pickPaymentProof,
                  child: Container(
                    width: double.infinity,
                    height: 140.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 1.5,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: selectedImagePath != null
                        ? Stack(
                            children: [
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16.r),
                                  child: Image.file(
                                    File(selectedImagePath!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8.h,
                                right: 8.w,
                                child: CircleAvatar(
                                  backgroundColor: Colors.black54,
                                  radius: 14.r,
                                  child: Icon(Icons.edit,
                                      color: Colors.white, size: 14.sp),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.cloud_upload_outlined,
                                  color: ColorManager.secondaryColor,
                                  size: 32.sp,
                                ),
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                'Click to upload screenshot',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'JPEG, PNG files are allowed',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummary(double subtotal, double delivery, double total) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSmallSummaryRow(
              'Subtotal', '${subtotal.toStringAsFixed(0)} EGP'),
          SizedBox(height: 6.h),
          _buildSmallSummaryRow(
              'Delivery', '${delivery.toStringAsFixed(0)} EGP'),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Divider(height: 1, color: Colors.grey[300]),
          ),
          _buildSmallSummaryRow(
            'Total',
            '${total.toStringAsFixed(0)} EGP',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSmallSummaryRow(String label, String value,
      {bool isTotal = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 15.sp : 13.sp,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 15.sp : 13.sp,
            fontWeight: FontWeight.bold,
            color: valueColor ??
                (isTotal ? ColorManager.secondaryColor : Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummary(double subtotal, double delivery, double total) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: TextStyles.settingItemTitle,
          ),
          SizedBox(height: 12.h),
          _buildSummaryRow('Subtotal', '${subtotal.toStringAsFixed(0)} EGP'),
          SizedBox(height: 6.h),
          _buildSummaryRow('Delivery', '${delivery.toStringAsFixed(0)} EGP'),
          SizedBox(height: 12.h),
          Divider(height: 1, color: Colors.grey[300]),
          SizedBox(height: 12.h),
          _buildSummaryRow(
            'Total',
            '${total.toStringAsFixed(0)} EGP',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isTotal = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16.sp : 14.sp,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16.sp : 14.sp,
            fontWeight: FontWeight.bold,
            color: valueColor ??
                (isTotal ? ColorManager.secondaryColor : Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: _handleNextStep,
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorManager.secondaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _getButtonText(),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (currentPage < 2) ...[
              SizedBox(width: 8.w),
              Icon(Icons.arrow_forward, size: 18.sp),
            ],
          ],
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
        return 'Complete Order';
      default:
        return 'Next';
    }
  }

  void _handleNextStep() {
    // Calculate totals for potential bottom sheet usage
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

      // Show order summary bottom sheet before completing the order
      _showOrderSummaryBottomSheet(subtotal, delivery, total);
    }
  }

  void _goToNextPage() {
    pageController.animateToPage(
      currentPage + 1,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _updateAddressFields() {
    fullNameController.text = fullName;
    emailController.text = email;
    addressController.text = address;
    cityController.text = city;
    apartmentController.text = apartment;
    phoneController.text = phone;
  }

  void _showOrderSummaryBottomSheet(
      double subtotal, double delivery, double total) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
              left: 20.w,
              right: 20.w,
              top: 20.h,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                // Address details header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order Confirmation',
                      style: TextStyles.bold24Black,
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _updateAddressFields();
                        pageController.animateToPage(
                          1,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      icon: Icon(Icons.edit,
                          size: 16.sp, color: ColorManager.secondaryColor),
                      label: Text('Edit',
                          style: TextStyle(color: ColorManager.secondaryColor)),
                    )
                  ],
                ),
                SizedBox(height: 16.h),
                _buildDetailsCard(),
                SizedBox(height: 16.h),
                _buildOrderSummary(subtotal, delivery, total),
                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorManager.secondaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _completeOrder();
                    },
                    child: Text(
                      'Confirm & Place Order',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: ColorManager.blackColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    String paymentMethod = selectedPayment >= 0
        ? paymentOptions[selectedPayment]['title']
        : 'Not selected';

    if (selectedPayment >= 0 &&
        paymentOptions[selectedPayment]['requiresInput'] == true) {
      paymentMethod += '\n$walletPhone';
    }

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Name', fullName),
          _buildDetailRow('Phone', phone),
          _buildDetailRow('Address', '$address, $city'),
          if (apartment.isNotEmpty) _buildDetailRow('Apt', apartment),
          _buildDetailRow('Payment', paymentMethod),
          _buildDetailRow(
              'Delivery',
              selectedShipping >= 0
                  ? shippingTitles[selectedShipping]
                  : 'Not selected'),
        ],
      ),
    );
  }

  void _completeOrder() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(ColorManager.secondaryColor),
              ),
              SizedBox(height: 16.h),
              Text(
                'Processing your order...',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      // Get cart data
      final cartState = context.read<CartCubit>().state;
      final cartEntity = (cartState as dynamic).cartEntity as CartEntity;

      // Calculate totals
      double subtotal = cartEntity.calculateTotalPrice();
      double delivery =
          selectedShipping >= 0 ? shippingPrices[selectedShipping] : 0;
      double total = subtotal + delivery;

      // Create shipping address entity
      final shippingAddress = ShippingAddressEntity(
        namee: fullName,
        email: email,
        address: address,
        city: city,
        apartmentNumber: apartment,
        phoneNumber: phone,
      );

      // Get order service
      final orderService = GetIt.I<OrderService>();

      // Create order in Firebase
      final orderId = await orderService.createOrderFromCart(
        cartItems: cartEntity.cartItems,
        payWithCash: selectedPayment == 0, // Cash on Delivery
        shippingAddress: shippingAddress,
        subtotal: subtotal,
        deliveryFee: delivery,
        totalAmount: total,
        paymentProofUrl: paymentProofUrl,
      );

      // Clear the cart cubit
      context.read<CartCubit>().clearCart();

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success bottom sheet
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
      // Close loading dialog
      Navigator.of(context).pop();

      // Show error snackbar
      showCustomBar(
        context,
        'Failed to create order. Please try again.',
        type: MessageType.error,
      );
    }
  }
}
