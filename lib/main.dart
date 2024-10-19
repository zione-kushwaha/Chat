import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learning1/utils.dart';
import 'service/auth_service.dart';
import 'service/navigation_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setup();
  runApp(MyApp());
}

Future<void> setup() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setUpFirebase();
  await registerServices();
}

class MyApp extends StatelessWidget {
  final GetIt _geitit = GetIt.instance;
  late NavigationService _navigationService;
  late AuthService _authService;
  MyApp({super.key}) {
    _navigationService = _geitit.get<NavigationService>();
    _authService = _geitit.get<AuthService>();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigationService.navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        textTheme:
            GoogleFonts.montserratTextTheme(Theme.of(context).textTheme.apply(
                // bodyColor: Colors.white, // Default text color
                // displayColor: Colors.white, // Default display text color
                )),
        primarySwatch: Colors.blue,
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          backgroundColor: Theme.of(context).primaryColor,
        ),
      ),
      initialRoute: _authService.user == null ? 'login' : 'home',
      routes: _navigationService.routes,
    );
  }
}
