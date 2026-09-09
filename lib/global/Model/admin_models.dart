enum UserRole { farmer, buyer, superAdmin }

enum VerificationStatus { pending, inProgress, verified, rejected, suspended }

extension VerificationStatusExt on VerificationStatus {
  String get labelBn {
    switch (this) {
      case VerificationStatus.pending:
        return 'অপেক্ষমাণ (Pending ⏳)';
      case VerificationStatus.inProgress:
        return 'প্রক্রিয়াধীন (In Progress 🔄)';
      case VerificationStatus.verified:
        return 'যাচাইকৃত (Verified ✅)';
      case VerificationStatus.rejected:
        return 'বাতিল (Rejected ❌)';
      case VerificationStatus.suspended:
        return 'সাময়িক স্থগিত (Suspended 🚫)';
    }
  }
}

enum ProductUnit { kg, mon, ton }

extension ProductUnitExt on ProductUnit {
  String get labelBn {
    switch (this) {
      case ProductUnit.kg:
        return 'কেজি';
      case ProductUnit.mon:
        return 'মন';
      case ProductUnit.ton:
        return 'টন';
    }
  }
}

enum OrderStatus {
  pending,
  paymentConfirmed,
  collectionVerified,
  inTransit,
  collected,
  preparing,
  delivered,
  completed,
  disputed,
  cancelled,
}

extension OrderStatusExt on OrderStatus {
  String get labelBn {
    switch (this) {
      case OrderStatus.pending:
        return 'অপেক্ষমাণ';
      case OrderStatus.paymentConfirmed:
        return 'পেমেন্ট কনফার্মড';
      case OrderStatus.collectionVerified:
        return 'হাব যাচাই সম্পন্ন';
      case OrderStatus.inTransit:
        return 'পরিবহনে চলমান';
      case OrderStatus.collected:
        return 'পণ্য সংগৃহীত';
      case OrderStatus.preparing:
        return 'প্রস্তুত হচ্ছে';
      case OrderStatus.delivered:
        return 'ডেলিভারি সম্পন্ন';
      case OrderStatus.completed:
        return 'সম্পন্ন (Completed ✅)';
      case OrderStatus.disputed:
        return 'অভিযোগাধীন';
      case OrderStatus.cancelled:
        return 'বাতিল';
    }
  }
}

class UserDetailRecord {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String nid;
  final String location;
  final UserRole role;
  final VerificationStatus status;
  final String? farmerType;
  final String? storeName;
  final String? tradeLicenseNo;
  final String? businessLicenseNo;
  final String nidFrontUrl;
  final String nidBackUrl;
  final String? tradeLicenseUrl;
  final String? photoUrl;
  final String? krishiCardDocUrl;
  final String adminNotes;
  final VerificationStatus nidStatus;
  final String nidRejectionNote;

  UserDetailRecord({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.nid,
    required this.location,
    required this.role,
    required this.status,
    this.farmerType,
    this.storeName,
    this.tradeLicenseNo,
    this.businessLicenseNo,
    required this.nidFrontUrl,
    required this.nidBackUrl,
    this.tradeLicenseUrl,
    this.photoUrl,
    this.krishiCardDocUrl,
    this.adminNotes = '',
    this.nidStatus = VerificationStatus.pending,
    this.nidRejectionNote = '',
  });
}

class FarmerVerificationRecord {
  final String id;
  final String name;
  final String phone;
  final String nid;
  final String location;
  final String farmerType;
  final String email;
  final VerificationStatus status;
  final String nidFrontUrl;
  final String nidBackUrl;
  final String? photoUrl;
  final String? krishiCardDocUrl;
  final String adminNotes;
  final VerificationStatus nidStatus;
  final String nidRejectionNote;

  FarmerVerificationRecord({
    required this.id,
    required this.name,
    required this.phone,
    required this.nid,
    required this.location,
    required this.farmerType,
    required this.email,
    required this.status,
    required this.nidFrontUrl,
    required this.nidBackUrl,
    this.photoUrl,
    this.krishiCardDocUrl,
    this.adminNotes = '',
    this.nidStatus = VerificationStatus.pending,
    this.nidRejectionNote = '',
  });
}

class BuyerVerificationRecord {
  final String id;
  final String storeName;
  final String ownerName;
  final String tradeLicense;
  final String location;
  final int onTimePayPercent;
  final String email;
  final String phone;
  final String nid;
  final VerificationStatus status;
  final String nidFrontUrl;
  final String nidBackUrl;
  final String? tradeLicenseUrl;
  final String? businessLicenseNo;
  final String? photoUrl;
  final String adminNotes;
  final VerificationStatus nidStatus;
  final String nidRejectionNote;

  BuyerVerificationRecord({
    required this.id,
    required this.storeName,
    required this.ownerName,
    required this.tradeLicense,
    required this.location,
    required this.onTimePayPercent,
    required this.email,
    required this.phone,
    required this.nid,
    required this.status,
    required this.nidFrontUrl,
    required this.nidBackUrl,
    this.tradeLicenseUrl,
    this.businessLicenseNo,
    this.photoUrl,
    this.adminNotes = '',
    this.nidStatus = VerificationStatus.pending,
    this.nidRejectionNote = '',
  });
}

class AdminProductApprovalRecord {
  final String id;
  final String emoji;
  final String title;
  final String farmerName;
  final String location;
  final double quantity;
  final ProductUnit unit;
  final double pricePerUnit;
  final String qualityGrade;
  final bool isApproved;

  AdminProductApprovalRecord({
    required this.id,
    required this.emoji,
    required this.title,
    required this.farmerName,
    required this.location,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    required this.qualityGrade,
    required this.isApproved,
  });
}

class AdminDemandMonitoringRecord {
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

  AdminDemandMonitoringRecord({
    required this.id,
    required this.emoji,
    required this.title,
    required this.buyerStore,
    required this.deliveryLocation,
    required this.requiredQuantity,
    required this.unit,
    required this.budgetRange,
    required this.offersCount,
    required this.status,
  });
}

class AdminOrderRecord {
  final String id;
  final String orderNumber;
  final String productTitle;
  final String farmerName;
  final String buyerName;
  final double totalAmount;
  final OrderStatus orderStatus;
  final String transportStatusText;

  AdminOrderRecord({
    required this.id,
    required this.orderNumber,
    required this.productTitle,
    required this.farmerName,
    required this.buyerName,
    required this.totalAmount,
    required this.orderStatus,
    required this.transportStatusText,
  });
}

class AdminDisputeRecord {
  final String id;
  final String complainantName;
  final String storeName;
  final String problemType;
  final String description;
  final String resolutionNotes;
  final String status;

  AdminDisputeRecord({
    required this.id,
    required this.complainantName,
    required this.storeName,
    required this.problemType,
    required this.description,
    required this.resolutionNotes,
    required this.status,
  });
}

typedef OrderTrackingRecord = AdminOrderRecord;
typedef DisputeResolutionRecord = AdminDisputeRecord;
