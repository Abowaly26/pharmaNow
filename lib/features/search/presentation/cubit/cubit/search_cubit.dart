import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharma_now/features/search/presentation/cubit/cubit/search_state.dart';

import '../../../../../core/repos/medicine_repo/medicine_repo.dart';
import '../../../../../core/utils/backend_endpoint.dart';

class SearchCubit extends Cubit<SearchState> {
  final MedicineRepo _productrepo;
  Timer? _debounce;
  String _lastQuery = '';

  SearchCubit(this._productrepo) : super(SearchInitial());

  Future<void> searchProducts({required String query}) async {
    // Cancel the current timer if active
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    // Clean the input text
    final cleanQuery = query.trim();

    // If query is empty
    if (cleanQuery.isEmpty) {
      emit(SearchInitial());
      return;
    }

    // If query is the same as previous, no need to search again
    if (cleanQuery == _lastQuery && state is SearchSuccess) {
      return;
    }

    // Update last query
    _lastQuery = cleanQuery;

    // Use a timer to delay (debounce) to prevent frequent searches
    _debounce = Timer(Duration(milliseconds: 500), () async {
      // Show loading state
      emit(SearchLoading());

      try {
        // Execute search
        final response = await _productrepo.searchMedicines(
            path: BackendEndpoint.getMedicines, query: cleanQuery);

        // Process response
        response.fold(
          (error) => emit(SearchError(message: error.message)),
          (medicines) {
            // Debug output
            print(
                'Search results: ${medicines.length} items found for "$cleanQuery"');
            emit(SearchSuccess(products: medicines, searchQuery: cleanQuery));
          },
        );
      } catch (error) {
        // Handle unexpected errors
        print('Unexpected search error: $error');
        emit(SearchError(message: 'حدث خطأ غير متوقع: $error'));
      }
    });
  }

  // Reset state function
  void resetSearch() {
    _lastQuery = '';
    emit(SearchInitial());
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
