import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/features/home/presentation/views/medicine_details_view.dart';
import 'package:pharma_now/features/info_offers/presentation/views/widgets/info_offers_list_view_item.dart';

import '../../../../../core/enitites/medicine_entity.dart';

class InfoOffersListView extends StatelessWidget {
  const InfoOffersListView({super.key, required this.medicines});

  final List<MedicineEntity> medicines;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(bottom: 40.h),
      itemCount: medicines.length,
      shrinkWrap: false,
      scrollDirection: Axis.vertical,
      itemBuilder: (context, index) => GestureDetector(
        onTap: () {
          // Navigate to medicine details view
          Navigator.pushNamed(
            context,
            MedicineDetailsView.routeName,
            arguments: medicines[index],
          );
        },
        child: InfoOffersListViewItem(
          medicineEntity: medicines[index],
          index: index,
          onTap: () {
            // Navigate to medicine details view
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MedicineDetailsView(
                  medicineEntity: medicines[index],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
