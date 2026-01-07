import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharma_now/features/search/presentation/cubit/cubit/search_state.dart';
import 'package:pharma_now/core/repos/medicine_repo/medicine_repo.dart';
import 'package:flutter/foundation.dart';
import '../../../../../core/utils/backend_endpoint.dart';

class SearchCubit extends Cubit<SearchState> {
  final MedicineRepo _productrepo;
  Timer? _debounce;
  String _lastQuery = '';
  final List<String> _recentSearches = []; // List to store recent searches
  final int _maxRecentSearches = 5; // Maximum number of recent searches to keep

  SearchCubit(this._productrepo)
      : super(const SearchInitial()); // Pass empty list initially

  Future<void> searchProducts({required String query}) async {
    // Cancel the current timer if active
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    // Clean the input text
    final cleanQuery = query.trim();

    // If query is empty
    if (cleanQuery.isEmpty) {
      emit(SearchInitial(
          recentSearches:
              _recentSearches)); // Emit initial state with recent searches
      return;
    }

    // If query is the same as previous, no need to search again
    if (cleanQuery == _lastQuery && state is SearchSuccess) {
      return;
    }

    // Update last query
    _lastQuery = cleanQuery;

    // Use a timer to delay (debounce) to prevent frequent searches
    _debounce = Timer(const Duration(milliseconds: 500), () async {
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
            debugPrint(
                'Search results: ${medicines.length} items found for "$cleanQuery"');
            // Add the successful search query to recent searches
            _addRecentSearch(cleanQuery);
            emit(SearchSuccess(products: medicines, searchQuery: cleanQuery));
          },
        );
      } catch (error) {
        // Handle unexpected errors
        debugPrint('Unexpected search error: $error');
        emit(SearchError(message: 'Unexpected error: $error'));
      }
    });
  }

  // Method to add a search query to the recent searches list
  void _addRecentSearch(String query) {
    // Avoid adding duplicate recent searches
    _recentSearches.remove(query);
    // Add the new query to the beginning of the list
    _recentSearches.insert(0, query);
    // Keep only the latest _maxRecentSearches
    if (_recentSearches.length > _maxRecentSearches) {
      _recentSearches.removeRange(_maxRecentSearches, _recentSearches.length);
    }
  }

  // Reset state function
  void resetSearch() {
    _lastQuery = '';
    emit(SearchInitial(
        recentSearches:
            _recentSearches)); // Emit initial state with recent searches
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
