import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pharma_now/core/services/database_service.dart';

class FireStoreSevice implements DatabaseService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Future<void> addData({
    required String path,
    required Map<String, dynamic> data,
    String? documentId,
  }) async {
    if (documentId != null) {
      await firestore.collection(path).doc(documentId).set(data);
    } else {
      await firestore.collection(path).add(data);
    }
  }

  @override
  Future<dynamic> getData(
      {required String path,
      String? docuementId,
      Map<String, dynamic>? query}) async {
    if (docuementId != null) {
      var data = await firestore.collection(path).doc(docuementId).get();
      return data.data();
    } else {
      Query<Map<String, dynamic>> data = firestore.collection(path);

      if (query != null) {
        if (query['orderBy'] != null) {
          if (query['orderBy'] != null) {
            var orderByField = query['orderBy'];
            var descending = query['descending'];

            data = data.orderBy(orderByField, descending: descending);
          }
        }

        if (query['limit'] != null) {
          var limit = query['limit'];
          data = data.limit(limit);
        }
      }

      var result = await data.get();

      return result.docs.map((e) => e.data()).toList();
    }
  }

  @override
  Future<bool> checkIfDataExist(
      {required String path, required String docuementId}) async {
    var data = await firestore.collection(path).doc(docuementId).get();
    return data.exists;
  }

  @override
  Future<List<Map<String, dynamic>>> searchMedicines({
    required String path,
    required String query,
  }) async {
    // If query is empty, return empty list
    if (query.isEmpty || query.trim().isEmpty) {
      return [];
    }

    try {
      // Clean the query for better search
      String searchQuery = query.trim().toLowerCase();

      // Get all medicines from collection
      final QuerySnapshot snapshot = await firestore.collection(path).get();

      // Local filtering for more flexible search
      final List<Map<String, dynamic>> results = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final String name = (data['name'] ?? '').toString().toLowerCase();
        final String description =
            (data['description'] ?? '').toString().toLowerCase();
        final String code = (data['code'] ?? '').toString().toLowerCase();

        // Check if any of the fields contain our search query
        if (name.contains(searchQuery) ||
            description.contains(searchQuery) ||
            code.contains(searchQuery)) {
          // Add document ID to the data for reference
          final Map<String, dynamic> result = {...data};
          result['id'] = doc.id;
          results.add(result);
        }
      }

      return results;
    } catch (error) {
      print('Search error: $error');
      throw Exception('Search error : $error');
    }
  }
}
