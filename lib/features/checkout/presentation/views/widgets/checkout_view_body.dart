import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pharma_now/core/utils/color_manger.dart';
import 'package:pharma_now/features/checkout/presentation/views/widgets/checkout_steps.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharma_now/Cart/presentation/cubits/cart_cubit/cart_cubit.dart';
import 'package:pharma_now/features/home/presentation/ui_model/entities/cart_entity.dart';

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

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final cartEntity = (state as dynamic).cartEntity as CartEntity;
        double subtotal = cartEntity.calculateTotalPrice();
        double delivery = 30;
        double total = subtotal + delivery;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                ColorManager.primaryColor,
                ColorManager.primaryColor.withOpacity(0.95),
              ],
            ),
          ),
          child: Column(
            children: [
              // Header with progress
              Container(
                padding: EdgeInsets.all(24),
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
                  margin: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: PageView.builder(
                      controller: pageController,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          padding: EdgeInsets.all(24),
                          child: _buildPageContent(
                              index, subtotal, delivery, total),
                        );
                      },
                    ),
                  ),
                ),
              ),
              // Bottom section with button
              Container(
                padding: EdgeInsets.all(24),
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
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (currentPage == 2)
                          _buildPaymentSummary(subtotal, delivery, total),
                        SizedBox(height: 16),
                        _buildActionButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose Delivery Method',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Select how you\'d like to receive your order',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 32),
          _buildModernShippingOption(
            'Cash on Delivery',
            'Pay when your order arrives at your door',
            '40',
            Icons.local_shipping,
            0,
          ),
          SizedBox(height: 16),
          _buildModernShippingOption(
            'Online Payment',
            'Pay now and get faster processing',
            '40',
            Icons.payment,
            1,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressPage() {
    return Form(
      key: addressFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Address',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Where should we deliver your order?',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildModernTextField(
                    'Full Name',
                    Icons.person_outline,
                    TextInputType.text,
                    (v) => fullName = v,
                  ),
                  SizedBox(height: 16),
                  _buildModernTextField(
                    'Email Address',
                    Icons.email_outlined,
                    TextInputType.emailAddress,
                    (v) => email = v,
                  ),
                  SizedBox(height: 16),
                  _buildModernTextField(
                    'Street Address',
                    Icons.location_on_outlined,
                    TextInputType.text,
                    (v) => address = v,
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildModernTextField(
                          'City',
                          Icons.location_city_outlined,
                          TextInputType.text,
                          (v) => city = v,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildModernTextField(
                          'Apartment',
                          Icons.home_outlined,
                          TextInputType.text,
                          (v) => apartment = v,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  _buildModernTextField(
                    'Phone Number',
                    Icons.phone_outlined,
                    TextInputType.phone,
                    (v) => phone = v,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentPage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Choose your preferred payment method',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 32),
          _buildModernPaymentOption(
              'Apple Pay', 'assets/images/Apple pay.svg', 0),
          SizedBox(height: 16),
          _buildModernPaymentOption(
              'MasterCard', 'assets/images/MasterCard.svg', 1),
          SizedBox(height: 16),
          _buildModernPaymentOption('PayPal', 'assets/images/paypal.svg', 2),
        ],
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
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? ColorManager.secondaryColor.withOpacity(0.1)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? ColorManager.secondaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    isSelected ? ColorManager.secondaryColor : Colors.grey[400],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '$price EGP',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ColorManager.secondaryColor,
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
    Function(String) onChanged,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextFormField(
        keyboardType: inputType,
        onChanged: onChanged,
        validator: (v) =>
            v == null || v.isEmpty ? 'This field is required' : null,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.grey[600]),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          hintStyle: TextStyle(color: Colors.grey[600]),
        ),
      ),
    );
  }

  Widget _buildModernPaymentOption(
    String title,
    String assetPath,
    int index,
  ) {
    bool isSelected = selectedPayment == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPayment = index;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? ColorManager.secondaryColor.withOpacity(0.1)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? ColorManager.secondaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? ColorManager.secondaryColor.withOpacity(0.2)
                    : Colors.grey[400],
                borderRadius: BorderRadius.circular(8),
              ),
              child: SvgPicture.asset(
                assetPath,
                width: 24,
                height: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ),
            if (isSelected)
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: ColorManager.secondaryColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(double subtotal, double delivery, double total) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16),
          _buildSummaryRow('Subtotal', '${subtotal.toStringAsFixed(2)} EGP'),
          SizedBox(height: 8),
          _buildSummaryRow('Delivery', '${delivery.toStringAsFixed(2)} EGP'),
          SizedBox(height: 16),
          Divider(),
          SizedBox(height: 16),
          _buildSummaryRow('Total', '${total.toStringAsFixed(2)} EGP',
              isTotal: true),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(double subtotal, double delivery, double total) {
    return Container(
      padding: EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Summary',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 4),
          _buildSmallSummaryRow(
              'Subtotal', '${subtotal.toStringAsFixed(2)} EGP'),
          _buildSmallSummaryRow(
              'Delivery', '${delivery.toStringAsFixed(2)} EGP'),
          Divider(),
          _buildSmallSummaryRow('Total', '${total.toStringAsFixed(2)} EGP',
              isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSmallSummaryRow(String label, String value,
      {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: Colors.grey[800],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: FontWeight.bold,
            color: isTotal ? ColorManager.secondaryColor : Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: Colors.grey[800],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: FontWeight.bold,
            color: isTotal ? ColorManager.secondaryColor : Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _handleNextStep,
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorManager.secondaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _getButtonText(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (currentPage < 2) ...[
              SizedBox(width: 8),
              Icon(Icons.arrow_forward, size: 20),
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
    double delivery = 30;
    double total = subtotal + delivery;
    if (currentPage == 0) {
      if (selectedShipping == -1) {
        _showErrorSnackBar('Please select a delivery method');
        return;
      }
      _goToNextPage();
    } else if (currentPage == 1) {
      if (addressFormKey.currentState?.validate() != true) {
        return;
      }
      _goToNextPage();
    } else if (currentPage == 2) {
      if (selectedPayment == -1) {
        _showErrorSnackBar('Please select a payment method');
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showOrderSummaryBottomSheet(
      double subtotal, double delivery, double total) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Address details header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Delivery Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      pageController.animateToPage(
                        1,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    icon: Icon(Icons.edit, size: 16),
                    label: Text('Edit'),
                  )
                ],
              ),
              SizedBox(height: 12),
              _buildDetailsCard(),
              SizedBox(height: 24),
              _buildOrderSummary(subtotal, delivery, total),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorManager.secondaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _completeOrder();
                  },
                  child: Text('Confirm Order'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            Flexible(
              child: Text(
                value.isEmpty ? '-' : value,
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Divider(height: 1),
        SizedBox(height: 8),
      ],
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Name', fullName),
          SizedBox(height: 8),
          _buildDetailRow('Email', email),
          SizedBox(height: 8),
          _buildDetailRow('Address', '$address, $city, $apartment'),
          SizedBox(height: 8),
          _buildDetailRow('Phone', phone),
        ],
      ),
    );
  }

  void _completeOrder() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: Colors.green[600],
                  size: 48,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Order Successful!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Thank you for your order. We\'ll send you a confirmation email shortly.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorManager.secondaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Continue Shopping'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
