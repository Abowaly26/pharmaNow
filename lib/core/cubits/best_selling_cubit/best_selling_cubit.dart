import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:pharma_now/core/repos/medicine_repo/medicine_repo.dart';
import '../../enitites/medicine_entity.dart';
part 'best_selling_state.dart';

class BestSellingCubit extends Cubit<BestSellingState> {
  BestSellingCubit(this.medicineRepo) : super(BestSellingInitial());

  final MedicineRepo medicineRepo;

  Future<void> getBestSellingMedicines() async {
    emit(BestSellingLoading());
    final result = await medicineRepo.getBestSellingMedicines();
    result.fold(
      (failure) => emit(BestSellingFailure(failure.message)),
      (medicines) => emit(BestSellingSuccess(medicines)),
    );
  }
}
