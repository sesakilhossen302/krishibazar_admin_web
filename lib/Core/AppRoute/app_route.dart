import 'package:flutter/material.dart';
import '../../View/Screen/AdminMainScreen/admin_main_screen/admin_main_screen.dart';

class AppRoute {
  static const String mainScreen = '/';

  static Map<String, WidgetBuilder> routes = {
    mainScreen: (context) => const AdminMainScreen(),
  };
}
