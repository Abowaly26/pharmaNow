import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharma_now/features/home/presentation/views/widgets/medicines_list_view.dart';

import 'package:skeletonizer/skeletonizer.dart';
import '../../../../../core/cubits/medicines_cubit/medicine_cubit.dart';
import '../../../../../core/helper_functions/get_dummy_medicine.dart';
import '../../../../../core/widgets/custom_error_widget.dart';

class MedicineListViewBlocBuilder extends StatelessWidget {
  const MedicineListViewBlocBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MedicinesCubit, MedicinesState>(
      builder: (context, state) {
        if (state is MedicinesSuccess) {
          return MedicinesListView(
            medicines: state.medicines,
          );
        } else if (state is MedicinesFailure) {
          return CustomErrorWidget(message: state.errMessage);
        } else {
          return Skeletonizer(
            enabled: true,
            child: MedicinesListView(
              medicines: getDummyMedicines(),
            ),
          );
        }
      },
    );
  }
}
