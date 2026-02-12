import 'package:flutter/material.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Future<dynamic>? navigateTo(Widget page, {bool replace = false}) {
    if (replace) {
      return navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(builder: (_) => page),
      );
    }
    return navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  static Future<dynamic>? pushNamedAndRemoveUntil(Widget page) {
    return navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => page),
      (route) => false,
    );
  }

  static void goBack() {
    return navigatorKey.currentState?.pop();
  }
}
