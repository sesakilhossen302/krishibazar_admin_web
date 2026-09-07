import '../../../../global/Model/admin_models.dart';

class VerificationModel {
  final List<FarmerVerificationRecord> farmers;
  final List<BuyerVerificationRecord> buyers;

  VerificationModel({required this.farmers, required this.buyers});
}
