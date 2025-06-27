import 'package:flutter/cupertino.dart';
import 'package:pharma_now/features/checkout/presentation/views/widgets/shipingItem.dart';

class ShipingSection extends StatefulWidget {
  const ShipingSection({super.key});

  @override
  State<ShipingSection> createState() => _ShipingSectionState();
}

class _ShipingSectionState extends State<ShipingSection> {
  int selectedIndex = -1;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 32,
        ),
        ShipingItem(
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
        ShipingItem(
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
