import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pharma_now/Cart/presentation/views/widgets/cart_view_body.dart';
import 'package:pharma_now/core/utils/color_manger.dart';
import 'package:pharma_now/features/checkout/presentation/views/widgets/active_item.dart';
import 'package:pharma_now/features/checkout/presentation/views/widgets/adressinputsection.dart';
import 'package:pharma_now/features/checkout/presentation/views/widgets/paymentsection.dart';
import 'package:pharma_now/features/checkout/presentation/views/widgets/shipingSection.dart';
import '../../../../../core/widgets/custom_buttom.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../../../home/presentation/ui_model/in_active_item.dart';
import 'checkout_steps.dart';
import 'inactive_item.dart';

class CheckoutViewBody extends StatefulWidget {
  const CheckoutViewBody({super.key});

  @override
  State<CheckoutViewBody> createState() => _CheckoutViewBodyState();
}

class _CheckoutViewBodyState extends State<CheckoutViewBody> {
  late PageController pageController;

  // متغيرات لحفظ بيانات كل خطوة
  int selectedShipping = -1;
  final addressFormKey = GlobalKey<FormState>();
  String fullName = '';
  String email = '';
  String address = '';
  String city = '';
  String apartment = '';
  String phone = '';
  int selectedPayment = -1;

  @override
  void initState() {
    pageController = PageController();
    pageController.addListener(() {
      setState(() {
        currentPage = pageController.page!.toInt();
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    pageController.dispose();
    super.dispose();
  }

  int currentPage = 0;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          CheckoutSteps(
            currentPage: currentPage,
            pageController: pageController,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: PageView.builder(
                  controller: pageController,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // Shipping
                      return Column(
                        children: [
                          SizedBox(height: 32),
                          _buildShippingOption('Cash on Delivery',
                              'Delivery to your location', '40', 0),
                          SizedBox(height: 16),
                          _buildShippingOption('Online Payment',
                              'Select payment method', '40', 1),
                        ],
                      );
                    } else if (index == 1) {
                      // Address
                      return Form(
                        key: addressFormKey,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              CustomTextFieldm(
                                hint: 'Full Name',
                                textInputType: TextInputType.text,
                                lable: '',
                                onChanged: (v) => fullName = v,
                                validator: (v) =>
                                    v == null || v.isEmpty ? 'Required' : null,
                              ),
                              CustomTextFieldm(
                                hint: 'Email',
                                textInputType: TextInputType.emailAddress,
                                lable: '',
                                onChanged: (v) => email = v,
                                validator: (v) =>
                                    v == null || v.isEmpty ? 'Required' : null,
                              ),
                              CustomTextFieldm(
                                hint: 'Address',
                                textInputType: TextInputType.text,
                                lable: '',
                                onChanged: (v) => address = v,
                                validator: (v) =>
                                    v == null || v.isEmpty ? 'Required' : null,
                              ),
                              CustomTextFieldm(
                                lable: '',
                                hint: 'City',
                                textInputType: TextInputType.text,
                                onChanged: (v) => city = v,
                                validator: (v) =>
                                    v == null || v.isEmpty ? 'Required' : null,
                              ),
                              CustomTextFieldm(
                                lable: '',
                                hint: 'Apartment Number',
                                textInputType: TextInputType.text,
                                onChanged: (v) => apartment = v,
                                validator: (v) =>
                                    v == null || v.isEmpty ? 'Required' : null,
                              ),
                              CustomTextFieldm(
                                lable: '',
                                hint: 'Phone Number',
                                textInputType: TextInputType.number,
                                onChanged: (v) => phone = v,
                                validator: (v) =>
                                    v == null || v.isEmpty ? 'Required' : null,
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      // Payment
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10),
                          _buildPaymentOption('Credit Card', 0),
                          SizedBox(height: 10),
                          _buildPaymentOption('PayPal', 1),
                          SizedBox(height: 30),
                          // Order summary (you can add more details)
                          Text('Order Summary:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          Text('Total: 180 EGP'),
                        ],
                      );
                    }
                  }),
            ),
          ),
          CustomButtom(
            text: getNextButtonText(currentPage),
            textStyle: TextStyle(
              fontStyle: FontStyle.normal,
              color: ColorManager.primaryColor,
              fontSize: 24,
            ),
            onButtonClicked: () {
              if (currentPage == 0) {
                if (selectedShipping == -1) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please select a shipping method')),
                  );
                  return;
                }
                pageController.animateToPage(currentPage + 1,
                    duration: Duration(milliseconds: 400),
                    curve: Curves.easeIn);
              } else if (currentPage == 1) {
                if (addressFormKey.currentState?.validate() != true) {
                  return;
                }
                pageController.animateToPage(currentPage + 1,
                    duration: Duration(milliseconds: 400),
                    curve: Curves.easeIn);
              } else if (currentPage == 2) {
                if (selectedPayment == -1) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please select a payment method')),
                  );
                  return;
                }
                _performCheckout();
              }
            },
            buttonColor: ColorManager.secondaryColor,
          ),
          SizedBox(
            height: 32,
          )
        ],
      ),
    );
  }

  Widget _buildShippingOption(
      String title, String subtitle, String price, int index) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Text('$price EGP'),
      leading: Radio<int>(
        value: index,
        groupValue: selectedShipping,
        onChanged: (v) {
          setState(() {
            selectedShipping = v!;
          });
        },
      ),
      onTap: () {
        setState(() {
          selectedShipping = index;
        });
      },
    );
  }

  Widget _buildPaymentOption(String title, int index) {
    return ListTile(
      title: Text(title),
      leading: Radio<int>(
        value: index,
        groupValue: selectedPayment,
        onChanged: (v) {
          setState(() {
            selectedPayment = v!;
          });
        },
      ),
      onTap: () {
        setState(() {
          selectedPayment = index;
        });
      },
    );
  }

  void _performCheckout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order Successful!'),
        content: Text('Thank you for using our app.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back after order
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}

List<Widget> getPages() {
  return [
    ShipingSection(),
    Adressinputsection(),
    PaymentSection(),
  ];
}

String getNextButtonText(int currentIndex) {
  switch (currentIndex) {
    case 0:
      return "Next";
    case 1:
      return "Next";
    case 2:
      return "Pay with PayPal";
    default:
      return "Next";
  }
}
