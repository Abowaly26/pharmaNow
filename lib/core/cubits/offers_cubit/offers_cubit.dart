import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:pharma_now/core/repos/medicine_repo/medicine_repo.dart';
import 'package:pharma_now/features/offers/presentation/views/widgets/inf_offers_view_body.dart';
import '../../enitites/medicine_entity.dart';
part 'offers_state.dart';

class OffersCubit extends Cubit<OffersState> {
  OffersCubit(
    this.medicineRepo,
  ) : super(OffersInitial());

  final MedicineRepo medicineRepo;

  Future<void> getMedicinesoffers() async {
    emit(OffersLoading());
    final result = await medicineRepo.getMedicinesoffers();
    result.fold(
      (failure) => emit(OffersFailure(failure.message)),
      (medicines) => emit(OffersSuccess(medicines)),
    );
  }
}
