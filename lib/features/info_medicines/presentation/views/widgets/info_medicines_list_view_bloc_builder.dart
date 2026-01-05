import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharma_now/core/cubits/medicines_cubit/medicine_cubit.dart';
import 'package:pharma_now/features/info_medicines/presentation/views/widgets/info_medicines_list_view.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../../core/helper_functions/get_dummy_medicine.dart';
import '../../../../../core/widgets/custom_error_widget.dart';

class MedicinesListViewBlocBuilder extends StatelessWidget {
  const MedicinesListViewBlocBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MedicinesCubit, MedicinesState>(
      builder: (context, state) {
        if (state is MedicinesSuccess) {
          return InfoMedicinesListView(
            medicines: state.medicines,
          );
        } else if (state is MedicinesFailure) {
          return CustomErrorWidget(message: state.errMessage);
        } else {
          return Skeletonizer(
            enabled: true,
            child: InfoMedicinesListView(
              medicines: getDummyMedicines(),
            ),
          );
        }
      },
    );
  }
}
