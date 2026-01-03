import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_now/core/enitites/medicine_entity.dart';
import 'package:pharma_now/core/utils/color_manger.dart';
import 'package:pharma_now/core/utils/text_styles.dart';
import 'package:pharma_now/core/widgets/search_highlight_text.dart';
import 'package:pharma_now/features/home/presentation/views/medicine_details_view.dart';
import 'package:pharma_now/features/search/presentation/cubit/cubit/search_cubit.dart';

/// A widget that displays search suggestions with highlighted matching text
class SearchSuggestionsList extends StatelessWidget {
  final String query;
  final List<MedicineEntity> suggestions;
  final VoidCallback? onSuggestionTap;

  const SearchSuggestionsList({
    super.key,
    required this.query,
    required this.suggestions,
    this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final medicine = suggestions[index];
          return _buildSuggestionItem(context, medicine);
        },
      ),
    );
  }

  Widget _buildSuggestionItem(BuildContext context, MedicineEntity medicine) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.h),
      leading: Container(
        width: 40.w,
        height: 40.h,
        decoration: BoxDecoration(
          color: ColorManager.lightBlueColorF5C,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: medicine.subabaseORImageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.network(
                  medicine.subabaseORImageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.medication,
                    color: ColorManager.primaryColor,
                    size: 20.sp,
                  ),
                ),
              )
            : Icon(
                Icons.medication,
                color: ColorManager.primaryColor,
                size: 20.sp,
              ),
      ),
      title: SearchHighlightText(
        text: medicine.name,
        query: query,
        defaultStyle: TextStyles.listView_product_name.copyWith(
          fontSize: 14.sp,
          color: ColorManager.blackColor,
        ),
        highlightColor: ColorManager.secondaryColor,
        highlightBackgroundColor: ColorManager.secondaryColor.withOpacity(0.12),
        highlightFontWeight: FontWeight.w500,
        caseSensitive: false,
      ),
      subtitle: Text(
        medicine.pharmacyName,
        style: TextStyle(
          fontSize: 12.sp,
          color: ColorManager.greyColor,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16.sp,
        color: ColorManager.greyColor,
      ),
      onTap: () {
        Navigator.pushNamed(
          context,
          MedicineDetailsView.routeName,
          arguments: medicine,
        );

        context.read<SearchCubit>().searchProducts(query: medicine.name);

        onSuggestionTap?.call();
      },
    );
  }
}
