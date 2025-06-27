import 'package:flutter/cupertino.dart';

abstract class AppDecoration{

  static var greyBoxDecoration=ShapeDecoration(

    color: Color(0x7ff2f3f3),
      shape: RoundedRectangleBorder(
          borderRadius:BorderRadius.circular(4) )

  );
}