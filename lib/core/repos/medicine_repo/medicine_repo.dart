import 'package:dartz/dartz.dart';
import 'package:pharma_now/core/enitites/medicine_entity.dart';

import '../../errors/failures.dart';

abstract class MedicineRepo {
  Future<Either<Failures, List<MedicineEntity>>> getMedicines();
  Future<Either<Failures, List<MedicineEntity>>> getBestSellingMedicines();
  Future<Either<Failures, List<MedicineEntity>>> getMedicinesoffers();
  Future<Either<Failures, List<MedicineEntity>>> searchMedicines({
    required String path,
    required String query,
  });
}
