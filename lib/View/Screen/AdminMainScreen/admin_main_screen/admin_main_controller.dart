import 'package:flutter/material.dart';
import '../../../../global/controller/admin_repository.dart';

class AdminMainController extends ChangeNotifier {
  final AdminRepository repository;

  AdminMainController(this.repository);

  int get selectedNavIndex => repository.activeNavIndex;

  void onNavSelected(int index) {
    repository.setActiveNavIndex(index);
    notifyListeners();
  }

  void setSearchQuery(String query) {
    repository.setSearchQuery(query);
  }
}
