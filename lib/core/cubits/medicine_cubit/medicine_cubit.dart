import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:pharma_now/core/repos/medicine_repo/medicine_repo.dart';

import '../../enitites/medicine_entity.dart';

part 'medicine_cubit_state.dart';

class MedicineCubit extends Cubit<MedicineCubitsState> {
  MedicineCubit(this.medicineRepo) : super(MedicineCubitsInitial());

  final MedicineRepo medicineRepo;

  Future<void> getMedicines() async {
    emit(MedicineCubitsLoading());
    final result = await medicineRepo.getMedicines();

    result.fold(
      (failure) => emit(MedicineCubitsfailure(failure.message)),
      (medicines) => emit(MedicineCubitsSuccess(medicines)),
    );
  }

  Future<void> getBestSellingMedicines() async {
    emit(MedicineCubitsLoading());
    final result = await medicineRepo.getBestSellingMedicines();

    result.fold(
      (failure) => emit(MedicineCubitsfailure(failure.message)),
      (medicines) => emit(MedicineCubitsSuccess(medicines)),
    );
  }
}
