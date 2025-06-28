import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import 'package:pharma_now/features/checkout/data/repositories/order_repository_impl.dart';
import 'package:pharma_now/features/checkout/data/services/order_service.dart';
import 'package:pharma_now/features/checkout/domain/repositories/order_repository.dart';

final getIt = GetIt.instance;

/// Initializes all order-related dependencies
void initOrderDependencies() {
  // Register Firebase services (if not already registered)
  if (!getIt.isRegistered<FirebaseAuth>()) {
    getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  }
  if (!getIt.isRegistered<FirebaseFirestore>()) {
    getIt.registerLazySingleton<FirebaseFirestore>(
        () => FirebaseFirestore.instance);
  }

  // Register repositories
  getIt.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(
      firestore: getIt<FirebaseFirestore>(),
      auth: getIt<FirebaseAuth>(),
    ),
  );

  // Register services
  getIt.registerLazySingleton<OrderService>(
    () => OrderService(),
  );
}
