import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../global/controller/admin_repository.dart';

class Dependency {
  static void init() {}

  static Widget wrapWithProviders(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdminRepository()),
      ],
      child: child,
    );
  }
}
