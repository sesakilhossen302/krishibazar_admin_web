import 'package:flutter/material.dart';
import '../../../../global/Model/admin_models.dart';
import '../../../../global/controller/admin_repository.dart';

class DisputesController extends ChangeNotifier {
  final AdminRepository repository;

  DisputesController(this.repository);

  List<DisputeResolutionRecord> get disputes => repository.disputes;
}
