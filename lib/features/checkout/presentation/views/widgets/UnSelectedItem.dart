import 'package:flutter/cupertino.dart';

class Unselecteditem extends StatelessWidget {
  const Unselecteditem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: ShapeDecoration(
          shape:OvalBorder(
            side: BorderSide(
              width: 1,
              color: Color(0xFF949D9E)
            )
          ) ),
    );
  }
}
