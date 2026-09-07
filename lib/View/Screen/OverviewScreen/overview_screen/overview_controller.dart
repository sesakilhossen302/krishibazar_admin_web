import 'package:flutter/material.dart';
import '../../../../global/Model/admin_models.dart';
import '../../../../global/controller/admin_repository.dart';

class OverviewController extends ChangeNotifier {
  final AdminRepository repository;

  OverviewController(this.repository);

  List<OrderTrackingRecord> get orders => repository.orders;
  List<DisputeResolutionRecord> get disputes => repository.disputes;
  List<FarmerVerificationRecord> get farmers => repository.farmers;
  List<BuyerVerificationRecord> get buyers => repository.buyers;
  double get totalVolume => orders.fold<double>(0, (sum, o) => sum + o.totalAmount);
}
