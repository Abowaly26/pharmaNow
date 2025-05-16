import 'package:flutter/material.dart';

// class CustomErrorWidget extends StatelessWidget {
//   const CustomErrorWidget({super.key, required this.text});
//   final String text;
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text(text),
//     );
//   }
// }
class CustomErrorWidget extends StatelessWidget {
  const CustomErrorWidget({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return SnackBar(
      content: Text(
        textAlign: TextAlign.center,
        message,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: const Color.fromARGB(255, 109, 193, 111),
      width: MediaQuery.of(context).size.width * 0.4,

      // Makes it narrower
      behavior: SnackBarBehavior.floating,
      // This makes it float and allows width customization
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(48),
      ),
      duration: const Duration(seconds: 1),
    );
  }
}
