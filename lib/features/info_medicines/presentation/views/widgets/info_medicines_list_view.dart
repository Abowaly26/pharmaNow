import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/features/home/presentation/views/medicine_details_view.dart';
import 'package:pharma_now/features/info_medicines/presentation/views/widgets/info_medicines_list_view_item.dart';
import '../../../../../core/enitites/medicine_entity.dart';

class InfoMedicinesListView extends StatelessWidget {
  const InfoMedicinesListView({super.key, required this.medicines});

  final List<MedicineEntity> medicines;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350.h,
      child: ListView.builder(
        itemCount: medicines.length,
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) => GestureDetector(
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
          child: InfoMedicinesListViewItem(
            medicineEntity: medicines[index],
            index: index,
            isFavorite: true,
            onFavoritePressed: () {},
          ),
        ),
      ),
    );
  }
}
