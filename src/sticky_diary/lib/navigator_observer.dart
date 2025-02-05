import 'package:flutter/material.dart';

class AppNavigatorObserver extends NavigatorObserver {
  final VoidCallback onPop;

  AppNavigatorObserver({required this.onPop});

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null && previousRoute.settings.name == 'add_entry') {
      onPop();
    }
  }
}
