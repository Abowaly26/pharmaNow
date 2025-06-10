import 'package:get_it/get_it.dart';
import 'package:pharma_now/core/repos/medicine_repo/medicine_repo.dart';
import 'package:pharma_now/core/services/database_service.dart';
import 'package:pharma_now/core/services/firebase_auth_service.dart';
import 'package:pharma_now/core/services/firestore_sevice.dart';
import 'package:pharma_now/features/auth/data/repos/auth_repo_impl.dart';
import 'package:pharma_now/features/auth/domain/repo/auth_repo.dart';
import 'package:pharma_now/features/cart/di/cart_injection.dart';
import 'package:pharma_now/features/favorites/di/favorites_injection.dart';
import 'package:pharma_now/features/search/presentation/cubit/cubit/search_cubit.dart';
import '../repos/medicine_repo/medicine_repo_impl.dart';

final getIt = GetIt.instance;

void setupGetit() {
  getIt.registerSingleton<FirebaseAuthService>(FirebaseAuthService());
  getIt.registerSingleton<DatabaseService>(FireStoreSevice());
  getIt.registerSingleton<AuthRepo>(AuthRepoImpl(
    firebaseAuthService: getIt<FirebaseAuthService>(),
    databaseService: getIt<DatabaseService>(),
  ));
  getIt.registerSingleton<MedicineRepo>(MedicineRepoImpl(
    getIt<DatabaseService>(),
  ));

  // Register SearchCubit
  getIt.registerFactory<SearchCubit>(() => SearchCubit(getIt<MedicineRepo>()));
  
  // Initialize Favorites dependencies
  FavoritesInjection.init();
  
  // Initialize Cart dependencies
  initCartDependencies();
}
