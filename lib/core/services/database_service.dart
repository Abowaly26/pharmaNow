import '../../features/auth/domain/repo/entities/user_entity.dart';

abstract class DatabaseService {
  Future<void> addData(
      {required String path,
      required Map<String, dynamic> data,
      String? documentId});
  Future<Map<String, dynamic>> getData(
      {required String path, required String docuementId});

  Future<bool> checkIfDataExist(
      {required String path, required String docuementId});
}
