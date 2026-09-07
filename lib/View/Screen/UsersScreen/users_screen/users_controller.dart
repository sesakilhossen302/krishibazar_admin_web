import 'package:flutter/material.dart';
import '../../../../global/Model/admin_models.dart';
import '../../../../global/controller/admin_repository.dart';

class UsersController extends ChangeNotifier {
  final AdminRepository repository;

  UsersController(this.repository);

  List<FarmerVerificationRecord> get farmers => repository.farmers;
  List<BuyerVerificationRecord> get buyers => repository.buyers;
}
