import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharma_now/core/cubits/medicines_cubit/medicine_cubit.dart';
import 'package:pharma_now/features/home/presentation/views/widgets/best_selling_list_view.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../core/helper_functions/get_dummy_medicine.dart';
import '../../../../../core/widgets/custom_error_widget.dart';

class BestSellingListViewBlocBuilder extends StatelessWidget {
  const BestSellingListViewBlocBuilder({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MedicineCubit, MedicineState>(
      builder: (context, state) {
        if (state is MedicineSuccess) {
          return BestSellingListView(
            medicines: state.medicines,
          );
        } else if (state is MedicineFailure) {
          return CustomErrorWidget(text: state.errMessage);
        } else {
          return Skeletonizer(
              enabled: true,
              child: BestSellingListView(
                medicines: getDummyMedicines(),
              ));
        }
      },
    );
  }
}
