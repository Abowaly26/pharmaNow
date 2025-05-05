import 'package:dartz/dartz.dart';
import 'package:pharma_now/core/enitites/medicine_entity.dart';
import 'package:pharma_now/core/errors/failures.dart';
import 'package:pharma_now/core/models/medicine_model.dart';
import 'package:pharma_now/core/repos/medicine_repo/medicine_repo.dart';
import 'package:pharma_now/core/services/database_service.dart';

import '../../utils/backend_endpoint.dart';

class MedicineRepoImpl extends MedicineRepo {
  final DatabaseService databaseService;

  MedicineRepoImpl(this.databaseService);
  @override
  Future<Either<Failures, List<MedicineEntity>>>
      getBestSellingMedicines() async {
    try {
      var data = await databaseService.getData(
        path: BackendEndpoint.getMedicines,
        query: {'limit': 10, 'orderBy': 'sellingCount', 'descending': true},
      ) as List<Map<String, dynamic>>;

      List<MedicineEntity> medicines =
          data.map((e) => MedicineModel.fromJson(e).toEntity()).toList();

      // List<MedicineEntity> entities = medicines.map((e) => e.toEntity()).toList();

      return Right(medicines);
    } catch (e) {
      return left(ServerFailure(
          'An error occurred on the server. Please try again later.'));
    }
  }

  @override
  Future<Either<Failures, List<MedicineEntity>>> getMedicines() async {
    try {
      var data = await databaseService.getData(
          path: BackendEndpoint.getMedicines) as List<Map<String, dynamic>>;

      List<MedicineEntity> medicines =
          data.map((e) => MedicineModel.fromJson(e).toEntity()).toList();

      // List<MedicineEntity> entities = medicines.map((e) => e.toEntity()).toList();

      return Right(medicines);
    } catch (e) {
      return left(ServerFailure(
          'An error occurred on the server. Please try again later.'));
    }
  }

  @override
  Future<Either<Failures, List<MedicineEntity>>> getMedicinesoffers() async {
    try {
      var data = await databaseService.getData(
        path: BackendEndpoint.getMedicines,
      ) as List<Map<String, dynamic>>;

      List<MedicineModel> medicineModels =
          data.map((e) => MedicineModel.fromJson(e)).toList();

      List<MedicineEntity> medicines = medicineModels
          .where((medicine) => medicine.discountRating > 0)
          .map((model) => model.toEntity())
          .toList();

      return Right(medicines);
    } catch (e) {
      return left(ServerFailure(
          'An error occurred on the server. Please try again later.'));
    }
  }
}
