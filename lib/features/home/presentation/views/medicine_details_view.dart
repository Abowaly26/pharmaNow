import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pharma_now/core/enitites/medicine_entity.dart';
import 'package:pharma_now/core/utils/color_manger.dart';
import 'package:pharma_now/features/home/presentation/views/main_view.dart';
import 'package:pharma_now/features/home/presentation/views/widgets/medicine_details_view_body.dart';

import '../../../../core/utils/app_images.dart';

class MedicineDetailsView extends StatelessWidget {
  static const String routeName = "ProductView";

  final MedicineEntity? medicineEntity;

  const MedicineDetailsView({
    super.key,
    this.medicineEntity,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: ColorManager.secondaryColor,
        title: Text(
          "Details",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, MainView.routeName);
          },
          icon: SvgPicture.asset(
            Assets.arrowLeft,
            width: 24,
            height: 24,
            color: ColorManager.primaryColor,
          ),
        ),
      ),
      body: medicineEntity != null
          ? MedicineDetailsViewBody(
              medicineEntity: medicineEntity!,
            )
          : Center(child: Text('Medicine details not available')),
    );
  }
}
