import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:pharma_now/core/repos/medicine_repo/medicine_repo.dart';

import '../../enitites/medicine_entity.dart';
part 'offers_state.dart';

class OffersCubit extends Cubit<OffersState> {
  OffersCubit(
    this.medicineRepo,
  ) : super(OffersInitial());

  final MedicineRepo medicineRepo;

  Future<void> getMedicinesoffers() async {
    emit(OffersLoading(state.medicines));
    final result = await medicineRepo.getMedicinesoffers();
    result.fold(
      (failure) => emit(OffersFailure(failure.message, state.medicines)),
      (medicines) => emit(OffersSuccess(medicines)),
    );
  }
}
