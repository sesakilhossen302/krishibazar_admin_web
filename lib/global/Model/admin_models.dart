enum UserRole {
  farmer('কৃষক / উৎপাদনকারী'),
  buyer('পাইকারি ক্রেতা / ব্যাপারি'),
  admin('কৃষি বাজার বোর্ড / অ্যাডমিন');

  final String labelBn;
  const UserRole(this.labelBn);
}

enum VerificationStatus {
  pending('অপেক্ষমাণ ⏳'),
  inProgress('প্রক্রিয়াধীন 🔄'),
  verified('যাচাইকৃত ✅'),
  rejected('বাতিল ❌'),
  suspended('সাময়িক স্থগিত 🚫');

  final String labelBn;
  const VerificationStatus(this.labelBn);
}

enum ProductCategory {
  vegetables('শাকসবজি', '🥦'),
  fruits('ফলমূল', '🍎'),
  paddy('ধান', '🌾'),
  rice('চাল', '🍚'),
  wheat('গম', '🌾'),
  potato('আলু', '🥔'),
  onion('পেঁয়াজ ও রসুন', '🧅'),
  fish('মাছ', '🐟'),
  other('অন্যান্য', '📦');

  final String labelBn;
  final String icon;
  const ProductCategory(this.labelBn, this.icon);
}

enum ProductUnit {
  kg('কেজি (kg)'),
  mon('মন'),
  ton('টন'),
  piece('পিস / সংখ্যা');

  final String labelBn;
  const ProductUnit(this.labelBn);
}

enum OrderStatus {
  completed('লেনদেন সম্পন্ন (Completed 🎉)'),
  inTransit('পরিবহনে পথে (In Transit 🚚)'),
  collected('সংগ্রহ কেন্দ্রে জমা (Collected)'),
  preparing('ফসল তোলা হচ্ছে (Preparing)'),
  pending('অপেক্ষমাণ'),
  disputed('অভিযোগ প্রক্রিয়াধীন'),
  cancelled('বাতিল');

  final String labelBn;
  const OrderStatus(this.labelBn);
}

enum TransportStatus {
  waiting('গাড়ি অপেক্ষমাণ'),
  driverAssigned('চালক নিযুক্ত'),
  inTransit('পথিমধ্যে রয়েছে'),
  delivered('গন্তব্যে পৌঁছেছে');

  final String labelBn;
  const TransportStatus(this.labelBn);
}

// User Record for Document Inspection Modal
class UserDetailRecord {
  final String id;
  final String name;
  final String phone;
  final String email;
  final UserRole role;
  final String nid;
  final String nidFrontUrl;
  final String nidBackUrl;
  final String location;

  // Buyer specific
  final String? storeName;
  final String? tradeLicenseNo;
  final String? tradeLicenseUrl;
  final String? businessLicenseNo;
  final int? onTimePayPercent;

  // Farmer specific
  final String? farmerType;

  VerificationStatus status;
  String adminNotes;

  UserDetailRecord({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    required this.nid,
    this.nidFrontUrl = 'https://images.unsplash.com/photo-1557804506-669a67965ba0?auto=format&fit=crop&w=600&q=80',
    this.nidBackUrl = 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=600&q=80',
    required this.location,
    this.storeName,
    this.tradeLicenseNo,
    this.tradeLicenseUrl = 'https://images.unsplash.com/photo-1450133064473-71024230f91b?auto=format&fit=crop&w=600&q=80',
    this.businessLicenseNo,
    this.onTimePayPercent,
    this.farmerType,
    this.status = VerificationStatus.verified,
    this.adminNotes = '',
  });
}

// Farmer Record for Verification
class FarmerVerificationRecord {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String nid;
  final String nidFrontUrl;
  final String nidBackUrl;
  final String location;
  final String farmerType;
  VerificationStatus status;
  String adminNotes;

  FarmerVerificationRecord({
    required this.id,
    required this.name,
    required this.phone,
    this.email = 'farmer@gmail.com',
    required this.nid,
    this.nidFrontUrl = 'https://images.unsplash.com/photo-1557804506-669a67965ba0?auto=format&fit=crop&w=600&q=80',
    this.nidBackUrl = 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=600&q=80',
    required this.location,
    required this.farmerType,
    this.status = VerificationStatus.verified,
    this.adminNotes = '',
  });
}

// Buyer Store Record for Verification
class BuyerVerificationRecord {
  final String id;
  final String storeName;
  final String ownerName;
  final String phone;
  final String email;
  final String nid;
  final String nidFrontUrl;
  final String nidBackUrl;
  final String tradeLicense;
  final String tradeLicenseUrl;
  final String businessLicenseNo;
  final String location;
  final int onTimePayPercent;
  VerificationStatus status;
  String adminNotes;

  BuyerVerificationRecord({
    required this.id,
    required this.storeName,
    required this.ownerName,
    required this.phone,
    this.email = 'buyer@gmail.com',
    this.nid = 'NID-7829102938',
    this.nidFrontUrl = 'https://images.unsplash.com/photo-1557804506-669a67965ba0?auto=format&fit=crop&w=600&q=80',
    this.nidBackUrl = 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=600&q=80',
    required this.tradeLicense,
    this.tradeLicenseUrl = 'https://images.unsplash.com/photo-1450133064473-71024230f91b?auto=format&fit=crop&w=600&q=80',
    this.businessLicenseNo = 'TR-DH-892102',
    required this.location,
    required this.onTimePayPercent,
    this.status = VerificationStatus.verified,
    this.adminNotes = '',
  });
}

// Product Approval Record
class ProductApprovalRecord {
  final String id;
  final String emoji;
  final String title;
  final String farmerName;
  final String location;
  final double quantity;
  final ProductUnit unit;
  final double pricePerUnit;
  final String qualityGrade;
  bool isApproved;

  ProductApprovalRecord({
    required this.id,
    required this.emoji,
    required this.title,
    required this.farmerName,
    required this.location,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    this.qualityGrade = 'গ্রেড A (প্রিমিয়াম)',
    this.isApproved = true,
  });
}

// Demand Monitoring Record
class DemandMonitoringRecord {
  final String id;
  final String emoji;
  final String title;
  final String buyerStore;
  final String deliveryLocation;
  final double requiredQuantity;
  final ProductUnit unit;
  final String budgetRange;
  final int offersCount;
  final String status;

  DemandMonitoringRecord({
    required this.id,
    required this.emoji,
    required this.title,
    required this.buyerStore,
    required this.deliveryLocation,
    required this.requiredQuantity,
    required this.unit,
    required this.budgetRange,
    required this.offersCount,
    this.status = 'সক্রিয় চাহিদা',
  });
}

// Order Tracking Record
class OrderTrackingRecord {
  final String id;
  final String orderNumber;
  final String productTitle;
  final double quantity;
  final ProductUnit unit;
  final String farmerName;
  final String buyerName;
  final double totalAmount;
  final String transportStatusText;
  final OrderStatus orderStatus;

  OrderTrackingRecord({
    required this.id,
    required this.orderNumber,
    required this.productTitle,
    required this.quantity,
    required this.unit,
    required this.farmerName,
    required this.buyerName,
    required this.totalAmount,
    required this.transportStatusText,
    required this.orderStatus,
  });
}

// Dispute Resolution Record
class DisputeResolutionRecord {
  final String id;
  final String complainantName;
  final String storeName;
  final String problemType;
  final String description;
  final String resolutionNotes;
  String status;

  DisputeResolutionRecord({
    required this.id,
    required this.complainantName,
    required this.storeName,
    required this.problemType,
    required this.description,
    required this.resolutionNotes,
    this.status = 'তদন্তাধীন (Under Review)',
  });
}
