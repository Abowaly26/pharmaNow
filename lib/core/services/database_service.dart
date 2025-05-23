abstract class DatabaseService {
  Future<void> addData(
      {required String path,
      required Map<String, dynamic> data,
      String? documentId});
  Future<dynamic> getData({
    required String path,
    String? docuementId,
    Map<String, dynamic>? query,
  });

  Future<bool> checkIfDataExist(
      {required String path, required String docuementId});

  Future<List<Map<String, dynamic>>> searchMedicines(
      {required String path, required String query});
}
