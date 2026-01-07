import 'package:flutter/cupertino.dart';
import 'package:pharma_now/features/checkout/presentation/views/widgets/shipping_item.dart';

class ShippingSection extends StatefulWidget {
  const ShippingSection({super.key});

  @override
  State<ShippingSection> createState() => _ShippingSectionState();
}

class _ShippingSectionState extends State<ShippingSection> {
  int selectedIndex = -1;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 32,
        ),
        ShippingItem(
          title: 'cash on delivery',
          subtitle: 'delivery at the location',
          price: '40',
          isSelected: selectedIndex == 0,
          onTap: () {
            selectedIndex = 0;
            setState(() {});
          },
        ),
        SizedBox(
          height: 16,
        ),
        ShippingItem(
          title: 'online payment',
          subtitle: 'select payment method',
          price: '40',
          isSelected: selectedIndex == 1,
          onTap: () {
            selectedIndex = 1;
            setState(() {});
          },
        )
      ],
    );
  }
}
