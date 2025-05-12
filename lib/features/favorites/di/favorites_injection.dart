import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import '../data/services/favorites_service.dart';
import '../presentation/providers/favorites_provider.dart';

class FavoritesInjection {
  static final GetIt sl = GetIt.instance;

  static void init() {
    // Register services
    sl.registerLazySingleton<FavoritesService>(() => FavoritesService());

    // Register providers
    sl.registerFactory<FavoritesProvider>(() => FavoritesProvider());
  }

  // Get favorites providers for use in MultiProvider
  static List<ChangeNotifierProvider> getFavoritesProviders() {
    return [
      ChangeNotifierProvider<FavoritesProvider>(
        create: (_) => sl<FavoritesProvider>(),
      ),
    ];
  }
}
