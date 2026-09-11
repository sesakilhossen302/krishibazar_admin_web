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

enum ProductUnit { kg, mon, ton, piece }

extension ProductUnitExt on ProductUnit {
  String get labelBn {
    switch (this) {
      case ProductUnit.kg:
        return 'কেজি';
      case ProductUnit.mon:
        return 'মন';
      case ProductUnit.ton:
        return 'টন';
      case ProductUnit.piece:
        return 'টি';
    }
  }
}

enum OrderStatus {
  pending,
  paymentPending,
  paymentConfirmed,
  collectionVerified,
  qualityRejected,
  inTransit,
  collected,
  preparing,
  delivered,
  completed,
  refunded,
  disputed,
  cancelled,
}

extension OrderStatusExt on OrderStatus {
  String get labelBn {
    switch (this) {
      case OrderStatus.pending:
        return 'অপেক্ষমাণ (ডিপোজিট বাকি)';
      case OrderStatus.paymentPending:
        return 'পেমেন্ট যাচাই পেন্ডিং ⏳';
      case OrderStatus.paymentConfirmed:
        return 'পেমেন্ট কনফার্মড 🔬';
      case OrderStatus.collectionVerified:
        return 'হাব মান যাচাই সম্পন্ন ⚖️';
      case OrderStatus.qualityRejected:
        return 'পণ্য মানসম্মত নয় (বাতিল) ❌';
      case OrderStatus.inTransit:
        return 'পরিবহনে চলমান 🚚';
      case OrderStatus.collected:
        return 'পণ্য সংগৃহীত';
      case OrderStatus.preparing:
        return 'প্রস্তুত হচ্ছে';
      case OrderStatus.delivered:
        return 'ডেলিভারি সম্পন্ন 📦';
      case OrderStatus.completed:
        return 'সম্পন্ন (Completed ✅)';
      case OrderStatus.refunded:
        return 'রিফান্ড সম্পন্ন 💰';
      case OrderStatus.disputed:
        return 'অভিযোগাধীন ⚠️';
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
  final int productsCount;
  final int offersCount;
  final int activeOrdersCount;
  final int completedOrders;
  final double totalEarnings;
  final double rating;
  final int reviewsCount;

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
    this.productsCount = 0,
    this.offersCount = 0,
    this.activeOrdersCount = 0,
    this.completedOrders = 0,
    this.totalEarnings = 0.0,
    this.rating = 0.0,
    this.reviewsCount = 0,
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
  final int productsCount;
  final int offersCount;
  final int activeOrdersCount;
  final int completedOrders;
  final double totalEarnings;
  final double rating;
  final int reviewsCount;

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
    this.productsCount = 0,
    this.offersCount = 0,
    this.activeOrdersCount = 0,
    this.completedOrders = 0,
    this.totalEarnings = 0.0,
    this.rating = 0.0,
    this.reviewsCount = 0,
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
  final int productsCount;
  final int offersCount;
  final int activeOrdersCount;
  final int completedOrders;
  final double totalEarnings;
  final double rating;
  final int reviewsCount;

  BuyerVerificationRecord({
    required this.id,
    required this.storeName,
    required this.ownerName,
    required this.tradeLicense,
    required this.location,
    this.onTimePayPercent = 100,
    required this.email,
    required this.phone,
    required this.nid,
    required this.status,
    this.nidFrontUrl = '',
    this.nidBackUrl = '',
    this.tradeLicenseUrl,
    this.businessLicenseNo,
    this.photoUrl,
    this.adminNotes = '',
    this.nidStatus = VerificationStatus.pending,
    this.nidRejectionNote = '',
    this.productsCount = 0,
    this.offersCount = 0,
    this.activeOrdersCount = 0,
    this.completedOrders = 0,
    this.totalEarnings = 0.0,
    this.rating = 0.0,
    this.reviewsCount = 0,
  });
}


class AdminProductApprovalRecord {
  final String id;
  final String farmerId;
  final String emoji;
  final String title;
  final String farmerName;
  final String farmerPhone;
  final String farmerPhotoUrl;
  final String farmerDistrict;
  final bool farmerVerified;
  final String location;
  final double quantity;
  final double remainingQuantity;
  final ProductUnit unit;
  final String unitLabel;
  final double pricePerUnit;
  final double minPrice;
  final String qualityGrade;
  final String category;
  final String harvestDate;
  final String availableDate;
  final String description;
  final List<String> imageUrls;
  final String? videoUrl;
  final String? videoNote;
  final bool isApproved;
  final String status;
  final String createdAt;

  AdminProductApprovalRecord({
    required this.id,
    this.farmerId = '',
    required this.emoji,
    required this.title,
    required this.farmerName,
    this.farmerPhone = '',
    this.farmerPhotoUrl = '',
    this.farmerDistrict = '',
    this.farmerVerified = true,
    required this.location,
    required this.quantity,
    double? remainingQuantity,
    required this.unit,
    String? unitLabel,
    required this.pricePerUnit,
    double? minPrice,
    required this.qualityGrade,
    this.category = 'শাকসবজি',
    this.harvestDate = '',
    this.availableDate = '',
    this.description = '',
    this.imageUrls = const [],
    this.videoUrl,
    this.videoNote,
    required this.isApproved,
    String? status,
    this.createdAt = '',
  })  : remainingQuantity = remainingQuantity ?? quantity,
        unitLabel = unitLabel ?? unit.labelBn,
        minPrice = minPrice ?? pricePerUnit,
        status = status ?? (isApproved ? 'active' : 'pending');
}

class AdminDemandMonitoringRecord {
  final String id;
  final String emoji;
  final String title;
  final String buyerId;
  final String buyerStore;
  final String buyerName;
  final String buyerPhone;
  final String buyerPhotoUrl;
  final bool buyerVerified;
  final String deliveryLocation;
  final double requiredQuantity;
  final ProductUnit unit;
  final String unitLabel;
  final double minExpectedPrice;
  final double maxExpectedPrice;
  final String budgetRange;
  final String qualityGrade;
  final int offersCount;
  final String status;
  final String category;
  final String description;
  final String deadlineDate;
  final String createdAt;

  AdminDemandMonitoringRecord({
    required this.id,
    required this.emoji,
    required this.title,
    this.buyerId = '',
    required this.buyerStore,
    this.buyerName = '',
    this.buyerPhone = '',
    this.buyerPhotoUrl = '',
    this.buyerVerified = false,
    required this.deliveryLocation,
    required this.requiredQuantity,
    required this.unit,
    String? unitLabel,
    this.minExpectedPrice = 0.0,
    this.maxExpectedPrice = 0.0,
    required this.budgetRange,
    this.qualityGrade = 'গ্রেড A',
    required this.offersCount,
    required this.status,
    this.category = 'শাকসবজি',
    this.description = '',
    this.deadlineDate = '',
    this.createdAt = '',
  }) : unitLabel = unitLabel ?? unit.labelBn;
}

class AdminOrderRecord {
  final String id;
  final String orderNumber;
  final String productTitle;
  final String category;
  final double quantity;
  final String unit;
  final double pricePerUnit;
  final String farmerId;
  final String farmerName;
  final String farmerPhone;
  final String farmerLocation;
  final String buyerId;
  final String buyerName;
  final String buyerPhone;
  final String buyerBusinessName;
  final double totalAmount;
  final double depositRequired;
  final bool isDepositPaid;
  final String paymentStatus;
  final String paymentVerificationNotes;
  final OrderStatus orderStatus;
  final String deliveryLocation;
  final String expectedDeliveryDate;

  // Transport
  final String pickupLocation;
  final String collectionCenter;
  final String driverName;
  final String driverPhone;
  final String vehicleNumber;
  final String transportStatus;
  final String transportStatusText;
  final String transportAgency;

  // Verification
  final double? actualWeight;
  final String qualityGrade;
  final String verifiedBy;
  final String verificationNotes;
  final bool isQualityVerified;
  final String inspectorName;
  final String inspectorDesignation;
  final bool? isQualityPassed;
  final String rejectionReason;

  // Refund
  final String refundStatus;
  final double refundAmount;
  final String refundNotes;

  final String createdAt;

  AdminOrderRecord({
    required this.id,
    required this.orderNumber,
    required this.productTitle,
    this.category = 'সবজি',
    this.quantity = 0,
    this.unit = 'কেজি (kg)',
    this.pricePerUnit = 0,
    this.farmerId = '',
    required this.farmerName,
    this.farmerPhone = '',
    this.farmerLocation = '',
    this.buyerId = '',
    required this.buyerName,
    this.buyerPhone = '',
    this.buyerBusinessName = '',
    required this.totalAmount,
    this.depositRequired = 0,
    this.isDepositPaid = false,
    this.paymentStatus = 'unpaid',
    this.paymentVerificationNotes = '',
    required this.orderStatus,
    this.deliveryLocation = '',
    this.expectedDeliveryDate = '',
    this.pickupLocation = '',
    this.collectionCenter = '',
    this.driverName = 'মোঃ রফিকুল ইসলাম',
    this.driverPhone = '01712-345678',
    this.vehicleNumber = 'ঢাকা মেট্রো-ট ১১-৪৫২৩',
    this.transportStatus = 'waiting',
    required this.transportStatusText,
    this.transportAgency = '',
    this.actualWeight,
    this.qualityGrade = 'গ্রেড A (প্রিমিয়াম মান)',
    this.verifiedBy = 'সেলিম রেজা (ইনস্পেক্টর)',
    this.verificationNotes = 'পণ্য ফ্রেশ ও পাকা ছিল',
    this.isQualityVerified = false,
    this.inspectorName = '',
    this.inspectorDesignation = '',
    this.isQualityPassed,
    this.rejectionReason = '',
    this.refundStatus = 'none',
    this.refundAmount = 0.0,
    this.refundNotes = '',
    this.createdAt = '',
  });

  factory AdminOrderRecord.fromJson(Map<String, dynamic> json) {
    OrderStatus st = OrderStatus.pending;
    final rawStatus = (json['order_status'] ?? 'pending').toString().toLowerCase();
    for (var s in OrderStatus.values) {
      if (s.name.toLowerCase() == rawStatus || s.labelBn.toLowerCase() == rawStatus) {
        st = s;
        break;
      }
    }

    final rawTr = (json['transport_status'] ?? 'waiting').toString();
    String trText = 'পিকআপের অপেক্ষায়';
    if (rawTr == 'in_transit' || rawTr == 'inTransit' || rawTr == 'onTheWay') {
      trText = 'ইন ট্রানজিট (পথে আছে)';
    } else if (rawTr == 'delivered' || rawTr == 'reached') {
      trText = 'ডেলিভারি সম্পন্ন';
    } else if (rawTr == 'pickup' || rawTr == 'loaded') {
      trText = 'সংগ্রহ ও লোড সম্পন্ন';
    }

    final double qty = (json['quantity'] is num)
        ? (json['quantity'] as num).toDouble()
        : (double.tryParse(json['quantity']?.toString() ?? '') ?? 0.0);

    final double price = (json['price_per_unit'] is num)
        ? (json['price_per_unit'] as num).toDouble()
        : (double.tryParse(json['price_per_unit']?.toString() ?? '') ?? 0.0);

    final double total = (json['total_amount'] is num)
        ? (json['total_amount'] as num).toDouble()
        : (double.tryParse(json['total_amount']?.toString() ?? '') ?? (qty * price));

    final double dep = (json['deposit_required'] is num)
        ? (json['deposit_required'] as num).toDouble()
        : (double.tryParse(json['deposit_required']?.toString() ?? '') ?? (total * 0.20));

    final double? actWeight = (json['actual_weight'] is num)
        ? (json['actual_weight'] as num).toDouble()
        : (double.tryParse(json['actual_weight']?.toString() ?? ''));

    final double refAmt = (json['refund_amount'] is num)
        ? (json['refund_amount'] as num).toDouble()
        : (double.tryParse(json['refund_amount']?.toString() ?? '') ?? 0.0);

    final bool isVerified = json['is_quality_verified'] == true ||
        st == OrderStatus.collectionVerified ||
        st == OrderStatus.inTransit ||
        st == OrderStatus.delivered ||
        st == OrderStatus.completed;

    return AdminOrderRecord(
      id: json['id']?.toString() ?? '',
      orderNumber: json['order_number']?.toString() ?? '',
      productTitle: json['product_title']?.toString() ?? '',
      category: json['category']?.toString() ?? 'সবজি',
      quantity: qty,
      unit: json['unit']?.toString() ?? 'কেজি (kg)',
      pricePerUnit: price,
      farmerId: json['farmer_id']?.toString() ?? '',
      farmerName: json['farmer_name']?.toString() ?? 'কৃষক',
      farmerPhone: json['farmer_phone']?.toString() ?? '',
      farmerLocation: json['farmer_location']?.toString() ?? '',
      buyerId: json['buyer_id']?.toString() ?? '',
      buyerName: json['buyer_name']?.toString() ?? 'ক্রেতা',
      buyerPhone: json['buyer_phone']?.toString() ?? '',
      buyerBusinessName: json['buyer_business_name']?.toString() ?? '',
      totalAmount: total,
      depositRequired: dep,
      isDepositPaid: json['is_deposit_paid'] == true,
      paymentStatus: (json['payment_status'] ?? 'unpaid').toString(),
      paymentVerificationNotes: (json['payment_verification_notes'] ?? '').toString(),
      orderStatus: st,
      deliveryLocation: json['delivery_location']?.toString() ?? '',
      expectedDeliveryDate: json['expected_delivery_date']?.toString() ?? '',
      pickupLocation: json['pickup_location']?.toString() ?? '',
      collectionCenter: json['collection_center']?.toString() ?? '',
      driverName: json['driver_name']?.toString() ?? 'মোঃ রফিকুল ইসলাম',
      driverPhone: json['driver_phone']?.toString() ?? '01712-345678',
      vehicleNumber: json['vehicle_number']?.toString() ?? 'ঢাকা মেট্রো-ট ১১-৪৫২৩',
      transportStatus: rawTr,
      transportStatusText: trText,
      transportAgency: (json['transport_agency'] ?? '').toString(),
      actualWeight: actWeight ?? qty,
      qualityGrade: json['quality_grade']?.toString() ?? 'গ্রেড A (প্রিমিয়াম মান)',
      verifiedBy: json['verified_by']?.toString() ?? 'সেলিম রেজা (ইনস্পেক্টর)',
      verificationNotes: json['verification_notes']?.toString() ?? 'পণ্য ফ্রেশ ও পাকা ছিল',
      isQualityVerified: isVerified,
      inspectorName: (json['inspector_name'] ?? '').toString(),
      inspectorDesignation: (json['inspector_designation'] ?? '').toString(),
      isQualityPassed: json['is_quality_passed'] as bool?,
      rejectionReason: (json['rejection_reason'] ?? '').toString(),
      refundStatus: (json['refund_status'] ?? 'none').toString(),
      refundAmount: refAmt,
      refundNotes: (json['refund_notes'] ?? '').toString(),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
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
