import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../global/controller/admin_repository.dart';
import '../farmer_verification_screen.dart';

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<AdminRepository>();
    return const FarmerVerificationScreen();
  }
}
