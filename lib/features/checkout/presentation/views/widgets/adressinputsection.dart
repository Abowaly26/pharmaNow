import 'package:flutter/cupertino.dart';

import '../../../../../core/widgets/custom_text_field.dart';

class Adressinputsection extends StatelessWidget {
  const Adressinputsection({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          CustomTextFieldm(
            hint: 'Full Name',
            textInputType: TextInputType.text,
            lable: '',
          ),
          CustomTextFieldm(
            hint: 'Email',
            textInputType: TextInputType.text,
            lable: '',
          ),
          CustomTextFieldm(
            hint: 'Address',
            textInputType: TextInputType.text,
            lable: '',
          ),
          CustomTextFieldm(
            lable: '',
            hint: 'City',
            textInputType: TextInputType.text,
          ),
          CustomTextFieldm(
            lable: '',
            hint: 'Apartment Number',
            textInputType: TextInputType.text,
          ),
          CustomTextFieldm(
            lable: '' '',
            hint: 'Phone Number',
            textInputType: TextInputType.number,
          )
        ],
      ),
    );
  }
}
