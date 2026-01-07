import 'package:flutter/cupertino.dart';

class UnSelectedItem extends StatelessWidget {
  const UnSelectedItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: ShapeDecoration(
          shape:
              OvalBorder(side: BorderSide(width: 1, color: Color(0xFF949D9E)))),
    );
  }
}
