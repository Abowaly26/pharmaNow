import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../enitites/medicine_entity.dart';
import '../../repos/medicine_repo/medicine_repo.dart';

part 'medicines_state.dart';

class MedicinesCubit extends Cubit<MedicinesState> {
  MedicinesCubit(this.medicineRepo) : super(MedicinesInitial());

  final MedicineRepo medicineRepo;

  Future<void> getMedicines() async {
    emit(MedicinesLoading());
    final result = await medicineRepo.getMedicines();
    result.fold(
      (failure) => emit(MedicinesFailure(failure.message)),
      (medicines) => emit(MedicinesSuccess(medicines)),
    );
  }
}
