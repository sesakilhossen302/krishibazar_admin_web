import 'package:flutter/material.dart';
import '../../../../global/Model/admin_models.dart';
import '../../../../global/controller/admin_repository.dart';

class OrdersController extends ChangeNotifier {
  final AdminRepository repository;

  OrdersController(this.repository);

  List<OrderTrackingRecord> get orders => repository.orders;
}
