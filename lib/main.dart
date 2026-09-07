import 'package:flutter/material.dart';
import 'Core/AppRoute/app_route.dart';
import 'Core/Dependency/dependency.dart';
import 'Utils/StaticString/static_string.dart';
import 'global/theme/light.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Dependency.init();
  runApp(
    Dependency.wrapWithProviders(const KrishiAdminWebApp()),
  );
}

class KrishiAdminWebApp extends StatelessWidget {
  const KrishiAdminWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: StaticString.appName,
      debugShowCheckedModeBanner: false,
      theme: lightTheme(),
      initialRoute: AppRoute.mainScreen,
      routes: AppRoute.routes,
    );
  }
}
