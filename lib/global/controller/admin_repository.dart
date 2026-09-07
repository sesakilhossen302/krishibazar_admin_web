import 'package:flutter/material.dart';
import '../Model/admin_models.dart';

class AdminRepository extends ChangeNotifier {
  List<FarmerVerificationRecord> _farmers = [];
  List<FarmerVerificationRecord> get farmers => _farmers;

  List<BuyerVerificationRecord> _buyers = [];
  List<BuyerVerificationRecord> get buyers => _buyers;

  List<AdminProductApprovalRecord> _products = [];
  List<AdminProductApprovalRecord> get products => _products;

  List<AdminDemandMonitoringRecord> _demands = [];
  List<AdminDemandMonitoringRecord> get demands => _demands;

  List<AdminOrderRecord> _orders = [];
  List<AdminOrderRecord> get orders => _orders;

  List<AdminDisputeRecord> _disputes = [];
  List<AdminDisputeRecord> get disputes => _disputes;

  UserDetailRecord? activeUserForDetail;
  int activeNavIndex = 0;
  String searchQuery = '';

  void setActiveNavIndex(int index) {
    activeNavIndex = index;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  AdminRepository() {
    _initDemoData();
  }

  void _initDemoData() {
    _farmers = [
      FarmerVerificationRecord(
        id: 'f1',
        name: 'মো: আব্দুল রহিম',
        phone: '01709-122333',
        nid: 'NID-7829102938',
        location: '📍 গোদাগাড়ী, রাজশাহী',
        farmerType: 'বাণিজ্যিক খামারি',
        email: 'abdul.rahim@gmail.com',
        status: VerificationStatus.verified,
        nidFrontUrl: 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?auto=format&fit=crop&w=600&q=80',
        nidBackUrl: 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=600&q=80',
      ),
      FarmerVerificationRecord(
        id: 'f2',
        name: 'খলিলুর রহমান',
        phone: '01892-120934',
        nid: 'NID-8829102940',
        location: '📍 বীরগঞ্জ, দিনাজপুর',
        farmerType: 'ধান ও গম চাষী',
        email: 'khalil.dinajpur@gmail.com',
        status: VerificationStatus.pending,
        nidFrontUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=600&q=80',
        nidBackUrl: 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=600&q=80',
      ),
    ];

    _buyers = [
      BuyerVerificationRecord(
        id: 'b1',
        storeName: 'মেসার্স সততা এগ্রো ট্রেডার্স',
        ownerName: 'আলহাজ্ব শফিকুল ইসলাম',
        tradeLicense: 'TR-Dhaka-9921',
        location: '📍 কারওয়ান বাজার, ঢাকা',
        onTimePayPercent: 98,
        email: 'shafiqul.karwan@gmail.com',
        phone: '01911-543210',
        nid: 'NID-1982910222',
        status: VerificationStatus.verified,
        nidFrontUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=600&q=80',
        nidBackUrl: 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=600&q=80',
        tradeLicenseUrl: 'https://images.unsplash.com/photo-1450133064473-71024230f91b?auto=format&fit=crop&w=600&q=80',
      ),
    ];

    _products = [
      AdminProductApprovalRecord(
        id: 'p1',
        emoji: '🥔',
        title: 'টাটকা ডায়মন্ড লাল আলু (গ্রেড A)',
        farmerName: 'মো: আব্দুল রহিম',
        location: 'রাজশাহী',
        quantity: 5000,
        unit: ProductUnit.kg,
        pricePerUnit: 28,
        qualityGrade: 'A+',
        isApproved: true,
      ),
      AdminProductApprovalRecord(
        id: 'p2',
        emoji: '🍅',
        title: 'দেশি পাকা টমেটো (১০০০ কেজি)',
        farmerName: 'খলিলুর রহমান',
        location: 'দিনাজপুর',
        quantity: 1000,
        unit: ProductUnit.kg,
        pricePerUnit: 40,
        qualityGrade: 'Grade A',
        isApproved: false,
      ),
    ];

    _demands = [
      AdminDemandMonitoringRecord(
        id: 'd1',
        emoji: '🧅',
        title: 'দেশি গোল পেঁয়াজ (জরুরি প্রয়োজন)',
        buyerStore: 'মেসার্স সততা এগ্রো ট্রেডার্স',
        deliveryLocation: 'কারওয়ান বাজার, ঢাকা',
        requiredQuantity: 3000,
        unit: ProductUnit.kg,
        budgetRange: '৳৬৫ - ৳৭২ / কেজি',
        offersCount: 3,
        status: 'সক্রিয় (Active)',
      ),
    ];

    _orders = [
      AdminOrderRecord(
        id: 'o1',
        orderNumber: 'KB-1001',
        productTitle: 'টাটকা ডায়মন্ড লাল আলু (৮০০ কেজি)',
        farmerName: 'মো: আব্দুল রহিম',
        buyerName: 'মেসার্স সততা এগ্রো ট্রেডার্স',
        totalAmount: 22400,
        orderStatus: OrderStatus.inTransit,
        transportStatusText: 'কালেকশন হাব ➔ গন্তব্যে চলমান',
      ),
    ];

    _disputes = [
      AdminDisputeRecord(
        id: 'dp1',
        complainantName: 'আলহাজ্ব শফিকুল ইসলাম',
        storeName: 'মেসার্স সততা এগ্রো',
        problemType: 'ওজনে সামান্য ঘাটতি (৫ কেজি কম)',
        description: 'আলুর ট্রাকে কালেকশন হাবে ওজনের সময় ৫ কেজি ঘাটতি পাওয়া গেছে।',
        resolutionNotes: 'অ্যাডমিন মধ্যস্থতায় ২% সমন্বয় করা হয়েছে।',
        status: 'নিষ্পত্তি হয়েছে ✅',
      ),
    ];
  }

  void openUserDetailFromFarmer(FarmerVerificationRecord farmer) {
    activeUserForDetail = UserDetailRecord(
      id: farmer.id,
      name: farmer.name,
      phone: farmer.phone,
      email: farmer.email,
      nid: farmer.nid,
      location: farmer.location,
      role: UserRole.farmer,
      status: farmer.status,
      farmerType: farmer.farmerType,
      nidFrontUrl: farmer.nidFrontUrl,
      nidBackUrl: farmer.nidBackUrl,
      adminNotes: farmer.adminNotes,
    );
    notifyListeners();
  }

  void openUserDetailFromBuyer(BuyerVerificationRecord buyer) {
    activeUserForDetail = UserDetailRecord(
      id: buyer.id,
      name: buyer.ownerName,
      phone: buyer.phone,
      email: buyer.email,
      nid: buyer.nid,
      location: buyer.location,
      role: UserRole.buyer,
      status: buyer.status,
      storeName: buyer.storeName,
      tradeLicenseNo: buyer.tradeLicense,
      businessLicenseNo: buyer.businessLicenseNo,
      nidFrontUrl: buyer.nidFrontUrl,
      nidBackUrl: buyer.nidBackUrl,
      tradeLicenseUrl: buyer.tradeLicenseUrl,
      adminNotes: buyer.adminNotes,
    );
    notifyListeners();
  }

  void closeUserDetail() {
    activeUserForDetail = null;
    notifyListeners();
  }

  void updateUserStatus({
    required String userId,
    required VerificationStatus status,
    required String adminNote,
  }) {
    // Update active user detail
    if (activeUserForDetail?.id == userId) {
      activeUserForDetail = UserDetailRecord(
        id: activeUserForDetail!.id,
        name: activeUserForDetail!.name,
        phone: activeUserForDetail!.phone,
        email: activeUserForDetail!.email,
        nid: activeUserForDetail!.nid,
        location: activeUserForDetail!.location,
        role: activeUserForDetail!.role,
        status: status,
        farmerType: activeUserForDetail!.farmerType,
        storeName: activeUserForDetail!.storeName,
        tradeLicenseNo: activeUserForDetail!.tradeLicenseNo,
        businessLicenseNo: activeUserForDetail!.businessLicenseNo,
        nidFrontUrl: activeUserForDetail!.nidFrontUrl,
        nidBackUrl: activeUserForDetail!.nidBackUrl,
        tradeLicenseUrl: activeUserForDetail!.tradeLicenseUrl,
        adminNotes: adminNote,
      );
    }

    final fIdx = _farmers.indexWhere((f) => f.id == userId);
    if (fIdx != -1) {
      _farmers[fIdx] = FarmerVerificationRecord(
        id: _farmers[fIdx].id,
        name: _farmers[fIdx].name,
        phone: _farmers[fIdx].phone,
        nid: _farmers[fIdx].nid,
        location: _farmers[fIdx].location,
        farmerType: _farmers[fIdx].farmerType,
        email: _farmers[fIdx].email,
        status: status,
        nidFrontUrl: _farmers[fIdx].nidFrontUrl,
        nidBackUrl: _farmers[fIdx].nidBackUrl,
        adminNotes: adminNote,
      );
    }

    final bIdx = _buyers.indexWhere((b) => b.id == userId);
    if (bIdx != -1) {
      _buyers[bIdx] = BuyerVerificationRecord(
        id: _buyers[bIdx].id,
        storeName: _buyers[bIdx].storeName,
        ownerName: _buyers[bIdx].ownerName,
        tradeLicense: _buyers[bIdx].tradeLicense,
        location: _buyers[bIdx].location,
        onTimePayPercent: _buyers[bIdx].onTimePayPercent,
        email: _buyers[bIdx].email,
        phone: _buyers[bIdx].phone,
        nid: _buyers[bIdx].nid,
        status: status,
        nidFrontUrl: _buyers[bIdx].nidFrontUrl,
        nidBackUrl: _buyers[bIdx].nidBackUrl,
        tradeLicenseUrl: _buyers[bIdx].tradeLicenseUrl,
        adminNotes: adminNote,
      );
    }

    notifyListeners();
  }

  void suspendUser({required String userId, required String adminNote}) {
    updateUserStatus(userId: userId, status: VerificationStatus.suspended, adminNote: adminNote);
  }

  void deleteUser({required String userId, required String adminNote}) {
    _farmers.removeWhere((f) => f.id == userId);
    _buyers.removeWhere((b) => b.id == userId);
    closeUserDetail();
  }

  void approveFarmer(String id) {
    updateUserStatus(userId: id, status: VerificationStatus.verified, adminNote: 'অ্যাডমিন কর্তৃক অনুমোদিত');
  }

  void rejectFarmer(String id) {
    updateUserStatus(userId: id, status: VerificationStatus.rejected, adminNote: 'তথ্য অসম্পূর্ণ থাকায় বাতিল');
  }

  void approveBuyer(String id) {
    updateUserStatus(userId: id, status: VerificationStatus.verified, adminNote: 'অ্যাডমিন কর্তৃক অনুমোদিত');
  }

  void rejectBuyer(String id) {
    updateUserStatus(userId: id, status: VerificationStatus.rejected, adminNote: 'লাইসেন্স ত্রুটি থাকায় বাতিল');
  }

  void approveProduct(String id) {
    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      _products[index] = AdminProductApprovalRecord(
        id: _products[index].id,
        emoji: _products[index].emoji,
        title: _products[index].title,
        farmerName: _products[index].farmerName,
        location: _products[index].location,
        quantity: _products[index].quantity,
        unit: _products[index].unit,
        pricePerUnit: _products[index].pricePerUnit,
        qualityGrade: _products[index].qualityGrade,
        isApproved: true,
      );
      notifyListeners();
    }
  }
}
