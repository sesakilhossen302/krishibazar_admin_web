import '../../../../global/Model/admin_models.dart';

class UsersModel {
  final List<FarmerVerificationRecord> farmers;
  final List<BuyerVerificationRecord> buyers;

  UsersModel({required this.farmers, required this.buyers});
}
