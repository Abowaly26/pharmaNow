import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../../core/cubits/offers_cubit/offers_cubit.dart';
import '../../../../../core/helper_functions/get_dummy_medicine.dart';
import '../../../../../core/widgets/custom_error_widget.dart';
import '../../../../info_offers/presentation/views/widgets/info_offers_list_view.dart';

class InfoOffersListViewBlocBuilder extends StatelessWidget {
  const InfoOffersListViewBlocBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OffersCubit, OffersState>(
      builder: (context, state) {
        if (state is OffersSuccess) {
          return InfoOffersListView(
            medicines: state.medicines,
          );
        } else if (state is OffersFailure) {
          return CustomErrorWidget(message: state.errMessage);
        } else {
          return Skeletonizer(
            enabled: true,
            child: InfoOffersListView(
              medicines: getDummyMedicines(),
            ),
          );
        }
      },
    );
  }
}
