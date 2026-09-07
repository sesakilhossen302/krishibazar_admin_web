import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../global/controller/admin_repository.dart';
import '../../VerificationScreen/buyer_verification_screen.dart';
import '../../VerificationScreen/farmer_verification_screen.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<AdminRepository>();
    return Column(
      children: const [
        Expanded(child: FarmerVerificationScreen()),
        Divider(),
        Expanded(child: BuyerVerificationScreen()),
      ],
    );
  }
}
