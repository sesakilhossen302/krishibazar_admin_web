import 'package:flutter/material.dart';
import '../Model/admin_models.dart';

class AdminRepository extends ChangeNotifier {
  int _activeNavIndex = 0;
  int get activeNavIndex => _activeNavIndex;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  List<FarmerVerificationRecord> _farmers = [];
  List<FarmerVerificationRecord> get farmers => _farmers;

  List<BuyerVerificationRecord> _buyers = [];
  List<BuyerVerificationRecord> get buyers => _buyers;

  List<ProductApprovalRecord> _products = [];
  List<ProductApprovalRecord> get products => _products;

  List<DemandMonitoringRecord> _demands = [];
  List<DemandMonitoringRecord> get demands => _demands;

  List<OrderTrackingRecord> _orders = [];
  List<OrderTrackingRecord> get orders => _orders;

  List<DisputeResolutionRecord> _disputes = [];
  List<DisputeResolutionRecord> get disputes => _disputes;

  UserDetailRecord? activeUserForDetail;
  String? toastMessage;

  AdminRepository() {
    _initData();
  }

  void _initData() {
    // 1. Farmers Verification Data
    _farmers = [
      FarmerVerificationRecord(
        id: 'f_1',
        name: 'মো: আব্দুল রহিম',
        phone: '০১৭০৯-১২২৩৩৩',
        email: 'abdul.rahim@gmail.com',
        nid: 'NID-7829102938',
        location: '📍 গোদাগাড়ী, রাজশাহী',
        farmerType: 'বাণিজ্যিক খামারি',
        status: VerificationStatus.verified,
        adminNotes: 'এনআইডি ও জমির তথ্য যাচাই সম্পন্ন হয়েছে।',
      ),
      FarmerVerificationRecord(
        id: 'f_2',
        name: 'করিম উল্লাহ মৃধা',
        phone: '০১৮১২-৩৪৫৬৭৮',
        email: 'karim.mridha@gmail.com',
        nid: 'NID-7829102938',
        location: '📍 শিবগঞ্জ, বগুড়া',
        farmerType: 'মাঝারি কৃষক',
        status: VerificationStatus.verified,
      ),
      FarmerVerificationRecord(
        id: 'f_3',
        name: 'খলিলুর রহমান',
        phone: '০১৯৮৭-৬৫৪৩২১',
        email: 'khalil.r@gmail.com',
        nid: 'NID-7829102938',
        location: '📍 ঝিকরগাছা, যশোর',
        farmerType: 'সবজি ও ফুল চাষী',
        status: VerificationStatus.verified,
      ),
      FarmerVerificationRecord(
        id: 'f_4',
        name: 'মো: আবুল কাশেম',
        phone: '০১৭৫১-৯৮৭৬৫০',
        email: 'kashem.b@gmail.com',
        nid: 'NID-7829102938',
        location: '📍 বীরগঞ্জ, দিনাজপুর',
        farmerType: 'বাণিজ্যিক ধান চাষী',
        status: VerificationStatus.verified,
      ),
      FarmerVerificationRecord(
        id: 'f_5',
        name: 'ফজলুল হক',
        phone: '০১৯১১-২২৩৩৪৪',
        email: 'fazlul.h@gmail.com',
        nid: 'NID-7829102938',
        location: '📍 সিংড়া, নাটোর',
        farmerType: 'রসুন ও ধানের কৃষক',
        status: VerificationStatus.verified,
      ),
      FarmerVerificationRecord(
        id: 'f_6',
        name: 'আনোয়ার হোসেন',
        phone: '০১৭৯৯-৮৮৭৭৬৬',
        email: 'anwar.h@gmail.com',
        nid: 'NID-7829102938',
        location: '📍 দামুড়হুদা, চুয়াডাঙ্গা',
        farmerType: 'আম ও পেয়ারা বাগান',
        status: VerificationStatus.pending,
        adminNotes: 'এনআইডি কার্ডের ছবি অস্পষ্ট, পুনঃআপলোড চাওয়া হয়েছে।',
      ),
      FarmerVerificationRecord(
        id: 'f_7',
        name: 'লোকমান হাকিম',
        phone: '০১৮৪৪-৬৭৭৮৮',
        email: 'lokman.h@gmail.com',
        nid: 'NID-7829102938',
        location: '📍 মধুপুর, টাঙ্গাইল',
        farmerType: 'আনারস ও পেঁপে খামারি',
        status: VerificationStatus.inProgress,
        adminNotes: 'কালেকশন এজেন্ট মাঠপর্যায়ে তথ্য পরিদর্শন করছেন।',
      ),
    ];

    // 2. Buyer Store Verification Data
    _buyers = [
      BuyerVerificationRecord(
        id: 'b_1',
        storeName: 'মিরপুর ফ্রেশ কিচেন সাপ্লাই',
        ownerName: 'ফারুক হোসেন',
        phone: '০১৯১১-৮৮৭৭৬৬',
        email: 'mirpur.fresh@gmail.com',
        tradeLicense: 'TR-DH-665512',
        location: '📍 সেকশন ১০, মিরপুর',
        onTimePayPercent: 93,
        status: VerificationStatus.verified,
        adminNotes: 'ট্রেড লাইসেন্স ও দোকানের ব্যাংক স্টেটমেন্ট সঠিক পাওয়া গেছে।',
      ),
      BuyerVerificationRecord(
        id: 'b_2',
        storeName: 'উত্তরা পাইকারি ঘর',
        ownerName: 'কামরুল হাসান',
        phone: '০১৭২২-৩৩৪৪৫৫',
        email: 'uttara.paikari@gmail.com',
        tradeLicense: 'TR-DH-223399',
        location: '📍 সেক্টর ৭, উত্তরা',
        onTimePayPercent: 98,
        status: VerificationStatus.verified,
      ),
      BuyerVerificationRecord(
        id: 'b_3',
        storeName: 'ক্যাপিটাল ফ্রেশ মার্ট',
        ownerName: 'মুস্তাফিজুর রহমান',
        phone: '০১৮৩৩-৪৪৫৫৬৬',
        email: 'capital.mart@gmail.com',
        tradeLicense: 'TR-DH-887711',
        location: '📍 রিং রোড, মোহাম্মদপুর',
        onTimePayPercent: 92,
        status: VerificationStatus.pending,
      ),
      BuyerVerificationRecord(
        id: 'b_4',
        storeName: 'বনানী অর্গানিক কর্নার',
        ownerName: 'জাহিদুল ইসলাম',
        phone: '০১৫৫৫-৬৬৭৭৮৮',
        email: 'banani.organic@gmail.com',
        tradeLicense: 'TR-DH-112233',
        location: '📍 রোড ১১, ব্লক ডি, বনানী',
        onTimePayPercent: 94,
        status: VerificationStatus.inProgress,
        adminNotes: 'ট্রেড লাইসেন্সের মেয়াদ যাচাই করা হচ্ছে।',
      ),
    ];

    // 3. Product Approval Data
    _products = [
      ProductApprovalRecord(
        id: 'p_1',
        emoji: '🥭',
        title: 'মধুপুরের হানিকুইন মিষ্টি আনারস',
        farmerName: 'লোকমান হাকিম',
        location: '📍 মধুপুর, টাঙ্গাইল',
        quantity: 3000,
        unit: ProductUnit.piece,
        pricePerUnit: 35,
        qualityGrade: 'গ্রেড A (প্রিমিয়াম)',
        isApproved: true,
      ),
      ProductApprovalRecord(
        id: 'p_2',
        emoji: '🥭',
        title: 'চুয়াডাঙ্গার থাই-৭ মিষ্টি পেয়ারা',
        farmerName: 'আনোয়ার হোসেন',
        location: '📍 দামুড়হুদা, চুয়াডাঙ্গা',
        quantity: 4000,
        unit: ProductUnit.kg,
        pricePerUnit: 48,
        qualityGrade: 'গ্রেড A (প্রিমিয়াম)',
        isApproved: false,
      ),
      ProductApprovalRecord(
        id: 'p_3',
        emoji: '🥬',
        title: 'রংপুরের হাইব্রিড কাঁচামরিচ',
        farmerName: 'সোহেল রানা',
        location: '📍 মিঠাপুকুর, রংপুর',
        quantity: 1200,
        unit: ProductUnit.kg,
        pricePerUnit: 90,
        qualityGrade: 'গ্রেড A (প্রিমিয়াম)',
        isApproved: true,
      ),
      ProductApprovalRecord(
        id: 'p_4',
        emoji: '📦',
        title: 'নাটোরের দেশি শুকনো রসুন',
        farmerName: 'ফজলুল হক',
        location: '📍 সিংড়া, নাটোর',
        quantity: 2000,
        unit: ProductUnit.kg,
        pricePerUnit: 160,
        qualityGrade: 'গ্রেড A (প্রিমিয়াম)',
        isApproved: true,
      ),
      ProductApprovalRecord(
        id: 'p_5',
        emoji: '🍚',
        title: 'মিনিকেট চাল (অটো রাইস মিল কোয়ালিটি)',
        farmerName: 'মো: আবুল কাশেম',
        location: '📍 বীরগঞ্জ, দিনাজপুর',
        quantity: 5000,
        unit: ProductUnit.kg,
        pricePerUnit: 68,
        qualityGrade: 'গ্রেড A (প্রিমিয়াম)',
        isApproved: true,
      ),
    ];

    // 4. Demand Monitoring Data
    _demands = [
      DemandMonitoringRecord(
        id: 'd_1',
        emoji: '🥬',
        title: 'টমেটো (Tomato)',
        buyerStore: 'কাওরান বাজার পাইকারি আড়ত',
        deliveryLocation: 'কাওরান বাজার আড়ত, ঢাকা',
        requiredQuantity: 2000,
        unit: ProductUnit.kg,
        budgetRange: '৳৪০-৪৫',
        offersCount: 3,
      ),
      DemandMonitoringRecord(
        id: 'd_2',
        emoji: '🥔',
        title: 'ডায়মন্ড গোল আলু (Potato)',
        buyerStore: 'স্বপ্ন সুপারশপ সাপ্লাই',
        deliveryLocation: 'তেজগাঁও সেন্ট্রাল ওয়্যারহাউস, ঢাকা',
        requiredQuantity: 5000,
        unit: ProductUnit.kg,
        budgetRange: '৳২৭-৩০',
        offersCount: 2,
      ),
      DemandMonitoringRecord(
        id: 'd_3',
        emoji: '🧅',
        title: 'দেশি লাল পেঁয়াজ (Onion)',
        buyerStore: 'আগোরা ফ্রেশ নেটওয়ার্ক',
        deliveryLocation: 'গুলশান ডিস্ট্রিবিউশন হাব, ঢাকা',
        requiredQuantity: 3000,
        unit: ProductUnit.kg,
        budgetRange: '৳৮২-৮৮',
        offersCount: 3,
      ),
      DemandMonitoringRecord(
        id: 'd_4',
        emoji: '🥬',
        title: 'বাঁধাকপি (Cabbage)',
        buyerStore: 'স্বপ্ন সুপারশপ সাপ্লাই',
        deliveryLocation: 'তেজগাঁও ওয়্যারহাউস, ঢাকা',
        requiredQuantity: 1500,
        unit: ProductUnit.piece,
        budgetRange: '৳২২-২৬',
        offersCount: 2,
      ),
    ];

    // 5. Order Tracking Data
    _orders = [
      OrderTrackingRecord(
        id: 'ord_1',
        orderNumber: '#KB-1001',
        productTitle: 'মিষ্টি পাকা টমেটো — ১০০০০ কেজি (kg)',
        farmerName: 'মো: আব্দুল রহিম (কৃষক)',
        buyerName: 'কাওরান বাজার পাইকারি আড়ত (ক্রেতা)',
        quantity: 10000,
        unit: ProductUnit.kg,
        totalAmount: 400000,
        transportStatusText: 'পরিবহন: গন্তব্যে পৌঁছেছে',
        orderStatus: OrderStatus.completed,
      ),
      OrderTrackingRecord(
        id: 'ord_2',
        orderNumber: '#KB-1002',
        productTitle: 'ডায়মন্ড গোল আলু — ২৫০০ কেজি (kg)',
        farmerName: 'করিম উল্লাহ মৃধা (কৃষক)',
        buyerName: 'স্বপ্ন সুপারশপ সাপ্লাই (ক্রেতা)',
        quantity: 2500,
        unit: ProductUnit.kg,
        totalAmount: 70000,
        transportStatusText: 'পরিবহন: পথিমধ্যে রয়েছে',
        orderStatus: OrderStatus.inTransit,
      ),
      OrderTrackingRecord(
        id: 'ord_3',
        orderNumber: '#KB-1003',
        productTitle: 'পাবনার দেশি লাল পেঁয়াজ — ১৫০০ কেজি (kg)',
        farmerName: 'রফিকুল ইসলাম (কৃষক)',
        buyerName: 'আগোরা ফ্রেশ নেটওয়ার্ক (ক্রেতা)',
        quantity: 1500,
        unit: ProductUnit.kg,
        totalAmount: 127500,
        transportStatusText: 'পরিবহন: চালক নিযুক্ত',
        orderStatus: OrderStatus.collected,
      ),
      OrderTrackingRecord(
        id: 'ord_4',
        orderNumber: '#KB-1004',
        productTitle: 'তাঁজা বাঁধাকপি — ১০০০০ পিস / সংখ্যা',
        farmerName: 'খলিলুর রহমান (কৃষক)',
        buyerName: 'স্বপ্ন সুপারশপ সাপ্লাই (ক্রেতা)',
        quantity: 10000,
        unit: ProductUnit.piece,
        totalAmount: 230000,
        transportStatusText: 'পরিবহন: গাড়ি অপেক্ষমাণ',
        orderStatus: OrderStatus.preparing,
      ),
    ];

    // 6. Dispute Resolution Data
    _disputes = [
      DisputeResolutionRecord(
        id: 'disp_1',
        complainantName: 'ফারুক হোসেন',
        storeName: 'মিরপুর ফ্রেশ কিচেন',
        problemType: 'ওজনে গরমিল (Quantity Mismatch)',
        description: '৪০০ কেজি কাঁচামরিচ দেওয়ার কথা ছিল, কিন্তু সংগ্রহ কেন্দ্রে ডিজিটাল স্কেলে ৩৬০ কেজি পাওয়া গেছে। ৪০ কেজি ঘাটতি রয়েছে।',
        resolutionNotes: 'কালেকশন এজেন্টকে পুনঃযাচাই করতে বলা হয়েছে। কৃষকের সাথে যোগাযোগ চলছে।',
        status: 'তদন্তাধীন (Under Review)',
      ),
    ];
  }

  void setActiveNavIndex(int index) {
    _activeNavIndex = index;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Open User Detail Inspection Modal
  void openUserDetailFromFarmer(FarmerVerificationRecord farmer) {
    activeUserForDetail = UserDetailRecord(
      id: farmer.id,
      name: farmer.name,
      phone: farmer.phone,
      email: farmer.email,
      role: UserRole.farmer,
      nid: farmer.nid,
      nidFrontUrl: farmer.nidFrontUrl,
      nidBackUrl: farmer.nidBackUrl,
      location: farmer.location,
      farmerType: farmer.farmerType,
      status: farmer.status,
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
      role: UserRole.buyer,
      nid: buyer.nid,
      nidFrontUrl: buyer.nidFrontUrl,
      nidBackUrl: buyer.nidBackUrl,
      location: buyer.location,
      storeName: buyer.storeName,
      tradeLicenseNo: buyer.tradeLicense,
      tradeLicenseUrl: buyer.tradeLicenseUrl,
      businessLicenseNo: buyer.businessLicenseNo,
      onTimePayPercent: buyer.onTimePayPercent,
      status: buyer.status,
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
    // Check Farmer
    final fIdx = _farmers.indexWhere((f) => f.id == userId);
    if (fIdx != -1) {
      _farmers[fIdx].status = status;
      _farmers[fIdx].adminNotes = adminNote;
    }

    // Check Buyer
    final bIdx = _buyers.indexWhere((b) => b.id == userId);
    if (bIdx != -1) {
      _buyers[bIdx].status = status;
      _buyers[bIdx].adminNotes = adminNote;
    }

    closeUserDetail();
    toastMessage = "ইউজার স্ট্যাটাস সফলভাবে '${status.labelBn}' এ আপডেট করা হয়েছে!";
    notifyListeners();
  }

  void suspendUser({required String userId, required String adminNote}) {
    updateUserStatus(userId: userId, status: VerificationStatus.suspended, adminNote: adminNote);
    toastMessage = "ইউজার অ্যাকাউন্ট সাময়িক স্থগিত করা হয়েছে।";
  }

  void deleteUser({required String userId, required String adminNote}) {
    _farmers.removeWhere((f) => f.id == userId);
    _buyers.removeWhere((b) => b.id == userId);
    closeUserDetail();
    toastMessage = "ইউজার অ্যাকাউন্ট স্থায়ীভাবে মুছে ফেলা হয়েছে।";
    notifyListeners();
  }

  void approveFarmer(String farmerId) {
    updateUserStatus(userId: farmerId, status: VerificationStatus.verified, adminNote: 'অ্যাডমিন কর্তৃক অনুমোদিত');
  }

  void rejectFarmer(String farmerId) {
    updateUserStatus(userId: farmerId, status: VerificationStatus.rejected, adminNote: 'অ্যাডমিন কর্তৃক বাতিলকৃত');
  }

  void approveBuyer(String buyerId) {
    updateUserStatus(userId: buyerId, status: VerificationStatus.verified, adminNote: 'অ্যাডমিন কর্তৃক অনুমোদিত');
  }

  void rejectBuyer(String buyerId) {
    updateUserStatus(userId: buyerId, status: VerificationStatus.rejected, adminNote: 'অ্যাডমিন কর্তৃক বাতিলকৃত');
  }

  void approveProduct(String productId) {
    final idx = _products.indexWhere((p) => p.id == productId);
    if (idx != -1) {
      _products[idx].isApproved = true;
      toastMessage = "পণ্য লিস্টিং অনুমোদন করা হয়েছে!";
      notifyListeners();
    }
  }
}
