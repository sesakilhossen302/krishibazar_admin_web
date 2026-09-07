import 'package:flutter/material.dart';
import '../../../../global/Model/admin_models.dart';
import '../../../../global/controller/admin_repository.dart';

class VerificationController extends ChangeNotifier {
  final AdminRepository repository;

  VerificationController(this.repository);

  List<FarmerVerificationRecord> get farmers => repository.farmers;
  List<BuyerVerificationRecord> get buyers => repository.buyers;
}
