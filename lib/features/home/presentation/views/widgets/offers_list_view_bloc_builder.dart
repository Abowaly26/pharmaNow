import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharma_now/core/cubits/offers_cubit/offers_cubit.dart';
import 'package:pharma_now/features/home/presentation/views/widgets/offers_list_view.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../../core/helper_functions/get_dummy_medicine.dart';
import '../../../../../core/widgets/custom_error_widget.dart';

class OffersListViewBlocBuilder extends StatelessWidget {
  const OffersListViewBlocBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OffersCubit, OffersState>(
      builder: (context, state) {
        if (state is OffersSuccess) {
          return OffersListView(
            medicines: state.medicines,
          );
        } else if (state is OffersFailure) {
          return CustomErrorWidget(message: state.errMessage);
        } else {
          return Skeletonizer(
            enabled: true,
            child: OffersListView(
              medicines: getDummyMedicines(),
            ),
          );
        }
      },
    );
  }
}
