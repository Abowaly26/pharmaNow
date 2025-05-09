// import 'package:pharma_now/core/enitites/medicine_entity.dart';
// import 'package:pharma_now/core/services/database_service.dart';
// import 'package:pharma_now/core/utils/backend_endpoint.dart';

// class ApiService {
//   final DatabaseService _databaseService;

//   ApiService(this._databaseService);

//   Future<List<MedicineEntity>> searchMedicines(String query) async {
//     if (query.trim().isEmpty) {
//       return [];
//     }

//     try {
//       // Call the database service search method
//       final response = await _databaseService.searchMedicines(
//         path: BackendEndpoint.getMedicines,
//         query: query,
//       );

//       // If no results, return empty list
//       if (response.isEmpty) {
//         return [];
//       }

//       // Convert the raw data to MedicineEntity objects
//       List<MedicineEntity> medicines = response.map((e) {
//         return MedicineEntity(
//           id: e['id'] ?? '',
//           name: e['name'] ?? '',
//           pharmacyName: e['pharmacyName'] ?? '',
//           price: e['price'] ?? 0,
//           description: e['description'],
//           subabaseORImageUrl: e['subabaseORImageUrl'],
//           isNewProduct: e['isNewProduct'] ?? false,
//           discountRating: e['discountRating'] ?? 0,
//         );
//       }).toList();

//       return medicines;
//     } catch (e) {
//       print('Error searching medicines: $e');
//       throw Exception('Failed to search medicines: $e');
//     }
//   }
// }
