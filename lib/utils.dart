import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:learning1/service/media_service.dart';
import 'firebase_options.dart';
import 'service/alert_service.dart';
import 'service/auth_service.dart';
import 'service/database_service.dart';
import 'service/navigation_service.dart';
import 'service/storage_service.dart';

Future<void> setUpFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

// register the services
Future<void> registerServices() async {
  final GetIt getIt = GetIt.instance;
  getIt.registerSingleton<AuthService>(AuthService());
  getIt.registerSingleton<NavigationService>(NavigationService());
  getIt.registerSingleton<AlertService>(AlertService());
  getIt.registerSingleton<MediaService>(MediaService());
  getIt.registerSingleton<StorageService>(StorageService());
  getIt.registerSingleton<DatabaseService>(DatabaseService());
}
