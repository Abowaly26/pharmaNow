import 'package:get_it/get_it.dart';
import 'package:pharma_now/core/services/notification_log_service.dart';
import 'package:pharma_now/core/services/user_settings_service.dart';
import 'package:pharma_now/core/services/fcm_service.dart';
import 'package:pharma_now/core/services/fcm_token_manager.dart';
import 'package:pharma_now/core/services/notification_service.dart';
import 'package:pharma_now/core/repos/medicine_repo/medicine_repo.dart';
import 'package:pharma_now/core/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pharma_now/core/services/firebase_auth_service.dart';
import 'package:pharma_now/core/services/firestore_sevice.dart';
import 'package:pharma_now/core/services/supabase_storage.dart';
import 'package:pharma_now/features/auth/data/repos/auth_repo_impl.dart';
import 'package:pharma_now/features/auth/domain/repo/auth_repo.dart';
import 'package:pharma_now/features/cart/di/cart_injection.dart';
import 'package:pharma_now/features/checkout/di/order_injection.dart';
import 'package:pharma_now/features/favorites/di/favorites_injection.dart';
import 'package:pharma_now/features/search/presentation/cubit/cubit/search_cubit.dart';
import '../repos/medicine_repo/medicine_repo_impl.dart';

final getIt = GetIt.instance;

void setupGetit() {
  getIt.registerSingleton<FlutterLocalNotificationsPlugin>(
      FlutterLocalNotificationsPlugin());

  getIt.registerSingleton<FirebaseAuthService>(FirebaseAuthService());
  getIt.registerSingleton<DatabaseService>(FireStoreSevice());

  getIt.registerSingleton<GlobalKey<NavigatorState>>(
      GlobalKey<NavigatorState>());

  final databaseService = getIt<DatabaseService>();
  getIt.registerSingleton<NotificationLogService>(
      NotificationLogService(databaseService));
  getIt.registerSingleton<UserSettingsService>(
      UserSettingsService(databaseService));

  getIt.registerSingleton<FCMTokenManager>(FCMTokenManager(databaseService));
  getIt.registerSingleton<FCMService>(FCMService(
    getIt<FCMTokenManager>(),
    NotificationService.instance,
  ));

  getIt.registerSingleton<AuthRepo>(AuthRepoImpl(
    firebaseAuthService: getIt<FirebaseAuthService>(),
    databaseService: getIt<DatabaseService>(),
  ));
  getIt.registerSingleton<MedicineRepo>(MedicineRepoImpl(
    getIt<DatabaseService>(),
  ));

  getIt.registerFactory<SearchCubit>(() => SearchCubit(getIt<MedicineRepo>()));

  getIt.registerLazySingleton<SupabaseStorageService>(
      () => SupabaseStorageService());

  FavoritesInjection.init();

  initCartDependencies();

  initOrderDependencies();
}
