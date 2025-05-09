import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
        itemBuilder: (context, index) => InfoMedicinesListViewItem(
          medicineEntity: medicines[index],
          index: index,
          isFavorite: true,
          onFavoritePressed:
              () {}, // You'll need to provide actual product data here
        ),
      ),
    );
  }
}
