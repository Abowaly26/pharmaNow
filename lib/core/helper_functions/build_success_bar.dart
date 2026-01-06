import 'package:flutter/material.dart';
import 'package:pharma_now/core/helper_functions/build_error_bar.dart';

void buildSuccessBar(BuildContext context, String message) {
  showCustomBar(
    context,
    message,
    type: MessageType.success,
  );
}
