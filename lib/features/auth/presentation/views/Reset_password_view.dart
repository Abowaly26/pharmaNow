import 'package:flutter/material.dart';
import 'package:pharma_now/features/auth/presentation/views/widget/reset_view_body.dart';

class ResetPasswordView extends StatelessWidget {
  const ResetPasswordView({super.key, this.oobCode});
  final String? oobCode;
  static const String routeName = 'reset_password_view';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResetPasswordViewBody(oobCode: oobCode),
    );
  }
}
