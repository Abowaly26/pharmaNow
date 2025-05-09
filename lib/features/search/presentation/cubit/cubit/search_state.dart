import 'package:equatable/equatable.dart';
import '../../../../../core/enitites/medicine_entity.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

// Initial state that can include recent searches and recently viewed items
class SearchInitial extends SearchState {}

// Loading state when search is in progress
class SearchLoading extends SearchState {}

// Success state with search results
class SearchSuccess extends SearchState {
  final List<MedicineEntity> products;
  final String searchQuery;

  const SearchSuccess({
    required this.products,
    required this.searchQuery,
  });

  @override
  List<Object?> get props => [products, searchQuery];
}

// Error state with error message
class SearchError extends SearchState {
  final String message;

  const SearchError({required this.message});

  @override
  List<Object?> get props => [message];
}
