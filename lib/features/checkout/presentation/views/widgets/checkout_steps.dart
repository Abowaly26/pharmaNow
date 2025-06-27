import 'package:flutter/cupertino.dart';
import 'package:pharma_now/features/checkout/presentation/views/widgets/active_item.dart';
import 'package:pharma_now/features/checkout/presentation/views/widgets/inactive_item.dart';
import 'package:pharma_now/features/checkout/presentation/views/widgets/step_item.dart';
import 'package:pharma_now/features/home/presentation/ui_model/in_active_item.dart';

class CheckoutSteps extends StatelessWidget {
  const CheckoutSteps({super.key, required this.currentPage,
    required this.pageController});
final int currentPage;
final PageController pageController;
  @override
  Widget build(BuildContext context) {
    return Row(
      children:
        List.generate(namedSteps.length, (index)
        {
         return Expanded(child:
         GestureDetector(
           onTap: (){
             pageController.animateToPage(index,
                 duration:Duration(milliseconds: 300) ,
                 curve: Curves.easeIn);

           },
           child: StepItem(
             isactive:index<= currentPage,
             text: namedSteps[index],
             index: "${index+1}", ),
         ));
        }
        )
      ,
    );
  }
}
List<String>namedSteps=["shipping","addresses","payment",];
