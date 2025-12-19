import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import 'package:pharma_now/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:pharma_now/features/cart/domain/repositories/cart_repository.dart';

import '../../order/presentation/cubits/cart_cubit/cart_cubit.dart';

final getIt = GetIt.instance;

/// Initializes all cart-related dependencies
void initCartDependencies() {
  // Register Firebase services
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFirestore>(
      () => FirebaseFirestore.instance);

  // Register repositories
  getIt.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(
      firestore: getIt<FirebaseFirestore>(),
      auth: getIt<FirebaseAuth>(),
    ),
  );

  // Register cubits
  getIt.registerFactory(
    () => CartCubit(
      cartRepository: getIt<CartRepository>(),
    ),
  );
}
