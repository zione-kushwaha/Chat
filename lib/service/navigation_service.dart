import 'package:flutter/material.dart';
import 'package:learning1/pages/register_page.dart';

import '../pages/home_page.dart';
import '../pages/login_page.dart';

class NavigationService {
  late GlobalKey<NavigatorState> _navigatorKey;

  final Map<String, Widget Function(BuildContext)> _routes = {
    'login': (context) => const LoginPage(),
    'home': (context) => const HomePage(),
    'register': (context) => const RegisterPage(),
  };

  // getter to get the _navigatorKey
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;
  NavigationService() {
    _navigatorKey = GlobalKey<NavigatorState>();
  }

  // getter to reuturn the _routes
  Map<String, Widget Function(BuildContext)> get routes => _routes;

  void pushNamed(String routeName) {
    _navigatorKey.currentState!.pushNamed(routeName);
  }

  void pushReplacementNamed(String routeName) {
    _navigatorKey.currentState!.pushReplacementNamed(routeName);
  }

  void push(MaterialPageRoute route) {
    _navigatorKey.currentState!.push(route);
  }

  void pop() {
    _navigatorKey.currentState!.pop();
  }
}
