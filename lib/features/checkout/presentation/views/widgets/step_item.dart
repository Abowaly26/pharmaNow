import 'package:flutter/cupertino.dart';
import 'package:pharma_now/features/checkout/presentation/views/widgets/active_item.dart';
import 'package:pharma_now/features/checkout/presentation/views/widgets/inactive_item.dart';

class StepItem extends StatelessWidget {
  const  StepItem({super.key, required this.index, required this.text, required this.isactive,});
final String index, text;
final bool isactive;
  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: InActiveStepItem(text: text, index: index),
      secondChild: ActiveItem(text: text),
      crossFadeState: isactive? CrossFadeState.showSecond: CrossFadeState.showFirst,
      duration: Duration(microseconds: 300),

    );
  }
}
