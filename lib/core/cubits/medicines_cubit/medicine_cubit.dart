import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:pharma_now/core/repos/medicine_repo/medicine_repo.dart';

import '../../enitites/medicine_entity.dart';

part 'medicine_state.dart';

class MedicineCubit extends Cubit<MedicineState> {
  MedicineCubit(this.medicineRepo) : super(MedicineInitial());

  final MedicineRepo medicineRepo;

  Future<void> getMedicines() async {
    emit(MedicineLoading());
    final result = await medicineRepo.getMedicines();

    result.fold(
      (failure) => emit(MedicineFailure(failure.message)),
      (medicines) => emit(MedicineSuccess(medicines)),
    );
  }

  Future<void> getBestSellingMedicines() async {
    emit(MedicineLoading());
    final result = await medicineRepo.getBestSellingMedicines();

    result.fold(
      (failure) => emit(MedicineFailure(failure.message)),
      (medicines) => emit(MedicineSuccess(medicines)),
    );
  }

  Future<void> getMedicinesoffers() async {
    emit(MedicineLoading());
    final result = await medicineRepo.getMedicinesoffers();

    result.fold(
      (failure) => emit(MedicineFailure(failure.message)),
      (medicines) => emit(MedicineSuccess(medicines)),
    );
  }
}
