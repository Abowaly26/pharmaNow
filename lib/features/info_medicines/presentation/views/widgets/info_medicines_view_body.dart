import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharma_now/core/cubits/medicines_cubit/medicine_cubit.dart';
import 'package:pharma_now/features/info_medicines/presentation/views/widgets/info_medicines_list_view_bloc_builder.dart';

class InfoMedicinesViewBody extends StatefulWidget {
  const InfoMedicinesViewBody({super.key});

  @override
  _InfoMedicinesViewBodyState createState() => _InfoMedicinesViewBodyState();
}

class _InfoMedicinesViewBodyState extends State<InfoMedicinesViewBody> {
  @override
  void initState() {
    super.initState();
    context.read<MedicinesCubit>().getMedicines();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Expanded(child: MedicinesListViewBlocBuilder()),
      ],
    );
  }
}
