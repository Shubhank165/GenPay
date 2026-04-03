import 'package:flutter/material.dart';

import '../config/routes.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static void redirectToPhoneLogin() {
    final state = navigatorKey.currentState;
    if (state == null) return;
    state.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }
}
