import 'package:flutter/material.dart';
import '../../Core/Network/admin_api_service.dart';
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
  AdminProductApprovalRecord? activeProductForDetail;
  AdminDemandMonitoringRecord? activeDemandForDetail;

  int activeNavIndex = 0;
  String searchQuery = '';
  bool _isLoadingUsers = false;
  bool get isLoadingUsers => _isLoadingUsers;
  bool _isLoadingProducts = false;
  bool get isLoadingProducts => _isLoadingProducts;

  void setActiveNavIndex(int index) {
    activeNavIndex = index;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void openProductDetail(AdminProductApprovalRecord product) {
    activeProductForDetail = product;
    notifyListeners();
  }

  void closeProductDetail() {
    activeProductForDetail = null;
    notifyListeners();
  }

  void openDemandDetail(AdminDemandMonitoringRecord demand) {
    activeDemandForDetail = demand;
    notifyListeners();
  }

  void closeDemandDetail() {
    activeDemandForDetail = null;
    notifyListeners();
  }

  AdminRepository() {
    _initDemoData();
    fetchUsersFromBackend();
    fetchProductsFromBackend();
    fetchDemandsFromBackend();
  }

  Future<void> fetchUsersFromBackend() async {
    _isLoadingUsers = true;
    notifyListeners();

    try {
      final data = await AdminApiService.fetchAllUsers();
      if (data.isNotEmpty) {
        final List<FarmerVerificationRecord> loadedFarmers = [];
        final List<BuyerVerificationRecord> loadedBuyers = [];

        for (var u in data) {
          final role = (u['role'] ?? '').toString().toLowerCase();
          final id = u['id']?.toString() ?? '';
          final name = u['name']?.toString() ?? 'অজ্ঞাত';
          final phone = u['phone']?.toString() ?? '';
          final email = u['email']?.toString() ?? '';
          final nid = (u['nid_or_doc'] ?? '').toString();

          final List<String> locParts = [];
          if ((u['address'] ?? '').toString().isNotEmpty) locParts.add(u['address']);
          if ((u['union'] ?? '').toString().isNotEmpty) locParts.add(u['union']);
          if ((u['upazila'] ?? '').toString().isNotEmpty) locParts.add(u['upazila']);
          if ((u['district'] ?? '').toString().isNotEmpty) locParts.add(u['district']);
          final location = locParts.isNotEmpty ? locParts.join(', ') : (u['district'] ?? 'বাংলাদেশ');

          final rawStatus = (u['verification_status'] ?? '').toString().toLowerCase().replaceAll('_', '');
          VerificationStatus status = VerificationStatus.pending;
          if (rawStatus == 'verified') {
            status = VerificationStatus.verified;
          } else if (rawStatus == 'rejected') {
            status = VerificationStatus.rejected;
          } else if (rawStatus == 'inprogress') {
            status = VerificationStatus.inProgress;
          } else if (rawStatus == 'suspended') {
            status = VerificationStatus.suspended;
          } else {
            status = VerificationStatus.pending;
          }

          final adminNote = (u['admin_note'] ?? '').toString();
          final nidRejectionNote = (u['nid_rejection_note'] ?? '').toString();
          final rawNidStatus = (u['nid_status'] ?? '').toString().toLowerCase();
          VerificationStatus nidStatus = VerificationStatus.pending;
          if (rawNidStatus == 'verified') {
            nidStatus = VerificationStatus.verified;
          } else if (rawNidStatus == 'rejected') {
            nidStatus = VerificationStatus.rejected;
          }

          final nidFront = AdminApiService.formatMediaUrl(u['nid_front_url']);
          final nidBack = AdminApiService.formatMediaUrl(u['nid_back_url']);
          final photo = AdminApiService.formatMediaUrl(u['photo_url']);

          final productsCount = (u['products_count'] is num) ? (u['products_count'] as num).toInt() : 0;
          final offersCount = (u['offers_count'] is num) ? (u['offers_count'] as num).toInt() : 0;
          final activeOrdersCount = (u['active_orders_count'] is num) ? (u['active_orders_count'] as num).toInt() : 0;
          final completedOrders = (u['completed_orders'] is num) ? (u['completed_orders'] as num).toInt() : 0;
          final totalEarnings = (u['total_earnings'] is num) 
              ? (u['total_earnings'] as num).toDouble() 
              : ((u['total_spent'] is num) ? (u['total_spent'] as num).toDouble() : 0.0);
          final rating = (u['rating'] is num) ? (u['rating'] as num).toDouble() : 0.0;
          final reviewsCount = (u['reviews_count'] is num) ? (u['reviews_count'] as num).toInt() : 0;

          if (role == 'farmer') {
            loadedFarmers.add(FarmerVerificationRecord(
              id: id,
              name: name,
              phone: phone,
              nid: nid.isNotEmpty ? nid : 'NID নেই',
              location: location,
              farmerType: (u['farmer_type'] != null && u['farmer_type'].toString().isNotEmpty) ? u['farmer_type'] : 'সাধারণ কৃষক',
              email: email,
              status: status,
              nidFrontUrl: nidFront,
              nidBackUrl: nidBack,
              photoUrl: photo,
              krishiCardDocUrl: AdminApiService.formatMediaUrl(u['krishi_card_doc_url']),
              adminNotes: adminNote,
              nidStatus: nidStatus,
              nidRejectionNote: nidRejectionNote,
              productsCount: productsCount,
              offersCount: offersCount,
              activeOrdersCount: activeOrdersCount,
              completedOrders: completedOrders,
              totalEarnings: totalEarnings,
              rating: rating,
              reviewsCount: reviewsCount,
            ));
          } else {
            loadedBuyers.add(BuyerVerificationRecord(
              id: id,
              storeName: (u['business_name'] ?? '').toString().isNotEmpty ? u['business_name'] : name,
              ownerName: name,
              tradeLicense: (u['trade_info'] ?? '').toString().isNotEmpty ? u['trade_info'] : 'ট্রেড লাইসেন্স নেই',
              location: location,
              onTimePayPercent: (u['payment_reliability'] is num) ? (u['payment_reliability'] as num).toInt() : 98,
              email: email,
              phone: phone,
              nid: nid.isNotEmpty ? nid : 'NID নেই',
              status: status,
              nidFrontUrl: nidFront,
              nidBackUrl: nidBack,
              tradeLicenseUrl: AdminApiService.formatMediaUrl(u['trade_license_url']),
              businessLicenseNo: u['business_type'],
              photoUrl: photo,
              adminNotes: adminNote,
              nidStatus: nidStatus,
              nidRejectionNote: nidRejectionNote,
              productsCount: productsCount,
              offersCount: offersCount,
              activeOrdersCount: activeOrdersCount,
              completedOrders: completedOrders,
              totalEarnings: totalEarnings,
              rating: rating,
              reviewsCount: reviewsCount,
            ));
          }
        }

        if (loadedFarmers.isNotEmpty) {
          _farmers = loadedFarmers;
          // Re-link existing products if farmer photos were missing
          if (_products.isNotEmpty) {
            _products = _products.map((p) {
              if (p.farmerPhotoUrl.isEmpty) {
                final match = _farmers.cast<FarmerVerificationRecord?>().firstWhere(
                  (f) => f != null && (
                    (p.farmerId.isNotEmpty && f.id == p.farmerId) ||
                    f.name.trim().toLowerCase() == p.farmerName.trim().toLowerCase() ||
                    (p.farmerPhone.isNotEmpty && f.phone.replaceAll(RegExp(r'\D'), '') == p.farmerPhone.replaceAll(RegExp(r'\D'), ''))
                  ),
                  orElse: () => null,
                );
                if (match != null && match.photoUrl != null && match.photoUrl!.isNotEmpty) {
                  return AdminProductApprovalRecord(
                    id: p.id,
                    farmerId: p.farmerId.isNotEmpty ? p.farmerId : match.id,
                    farmerName: p.farmerName,
                    farmerPhone: p.farmerPhone.isNotEmpty ? p.farmerPhone : match.phone,
                    farmerPhotoUrl: match.photoUrl!,
                    farmerDistrict: p.farmerDistrict,
                    farmerVerified: p.farmerVerified || match.status == VerificationStatus.verified,
                    title: p.title,
                    category: p.category,
                    quantity: p.quantity,
                    remainingQuantity: p.remainingQuantity,
                    unit: p.unit,
                    unitLabel: p.unitLabel,
                    pricePerUnit: p.pricePerUnit,
                    minPrice: p.minPrice,
                    location: p.location,
                    availableDate: p.availableDate,
                    harvestDate: p.harvestDate,
                    qualityGrade: p.qualityGrade,
                    description: p.description,
                    imageUrls: p.imageUrls,
                    videoUrl: p.videoUrl,
                    videoNote: p.videoNote,
                    isApproved: p.isApproved,
                    createdAt: p.createdAt,
                    emoji: p.emoji,
                  );
                }
              }
              return p;
            }).toList();
          }
        }
        if (loadedBuyers.isNotEmpty) _buyers = loadedBuyers;

      }
    } catch (e) {
      debugPrint('Error loading backend users into Admin: $e');
    } finally {
      _isLoadingUsers = false;
      notifyListeners();
    }
  }

  Future<void> fetchProductsFromBackend() async {
    _isLoadingProducts = true;
    notifyListeners();

    try {
      final data = await AdminApiService.fetchAllProducts();
      if (data.isNotEmpty) {
        final List<AdminProductApprovalRecord> loaded = [];
        for (var p in data) {
          final id = p['id']?.toString() ?? '';
          final farmerId = p['farmer_id']?.toString() ?? '';
          final title = p['title']?.toString() ?? '';
          final farmerName = p['farmer_name']?.toString() ?? 'কৃষক';
          final location = p['location']?.toString() ?? p['farmer_district']?.toString() ?? 'বাংলাদেশ';
          final qty = (p['quantity'] is num) ? (p['quantity'] as num).toDouble() : 0.0;
          final remQty = (p['remaining_quantity'] is num) ? (p['remaining_quantity'] as num).toDouble() : qty;
          final price = (p['expected_price'] is num) ? (p['expected_price'] as num).toDouble() : 0.0;
          final minPrice = (p['min_price'] is num) ? (p['min_price'] as num).toDouble() : price;
          final qualityGrade = p['quality_grade']?.toString() ?? 'গ্রেড A';
          final category = p['category']?.toString() ?? 'শাকসবজি';
          final harvestDate = p['harvest_date']?.toString() ?? '';
          final availableDate = p['available_date']?.toString() ?? '';
          final description = p['description']?.toString() ?? '';
          final status = (p['status'] ?? 'active').toString();
          final isApproved = status == 'active';

          // Match with _farmers to retrieve farmer's uploaded photo and phone!
          final matchingFarmer = _farmers.cast<FarmerVerificationRecord?>().firstWhere(
            (f) => f != null && (f.id == farmerId || f.name.trim().toLowerCase() == farmerName.trim().toLowerCase()),
            orElse: () => null,
          );
          final farmerPhone = (p['farmer_phone']?.toString().isNotEmpty == true)
              ? p['farmer_phone'].toString()
              : (matchingFarmer?.phone ?? '');
          final farmerPhotoUrl = (matchingFarmer?.photoUrl != null && matchingFarmer!.photoUrl!.isNotEmpty)
              ? matchingFarmer.photoUrl!
              : AdminApiService.formatMediaUrl(p['farmer_photo']?.toString() ?? '');
          final farmerDistrict = p['farmer_district']?.toString() ?? '';
          final farmerVerified = p['farmer_verified'] == true || (matchingFarmer?.status == VerificationStatus.verified);

          // Images
          final List<String> imageUrls = [];
          if (p['images'] is List) {
            for (var img in (p['images'] as List)) {
              if (img != null && img.toString().isNotEmpty) {
                imageUrls.add(AdminApiService.formatMediaUrl(img.toString()));
              }
            }
          }
          if (imageUrls.isEmpty && (p['image_url'] ?? '').toString().isNotEmpty) {
            imageUrls.add(AdminApiService.formatMediaUrl(p['image_url'].toString()));
          }

          // Video
          String? videoUrl;
          if ((p['video_url'] ?? '').toString().isNotEmpty) {
            videoUrl = AdminApiService.formatMediaUrl(p['video_url'].toString());
          }
          final videoNote = p['video_note']?.toString();

          // Emoji
          String emoji = '🌾';
          if (category.contains('সবজি')) {
            emoji = '🥦';
          } else if (category.contains('ফল')) {
            emoji = '🍎';
          } else if (category.contains('ধান') || category.contains('চাল')) {
            emoji = '🌾';
          } else if (category.contains('ডাল')) {
            emoji = '🫘';
          } else if (category.contains('মসলা')) {
            emoji = '🌶️';
          } else if (title.contains('আলু')) {
            emoji = '🥔';
          } else if (title.contains('টমেটো')) {
            emoji = '🍅';
          } else if (title.contains('পেঁয়াজ')) {
            emoji = '🧅';
          }

          // Unit
          final rawUnit = p['unit']?.toString() ?? 'কেজি';
          ProductUnit unit = ProductUnit.kg;
          if (rawUnit.contains('মন')) {
            unit = ProductUnit.mon;
          } else if (rawUnit.contains('টন')) {
            unit = ProductUnit.ton;
          }

          loaded.add(AdminProductApprovalRecord(
            id: id,
            farmerId: farmerId,
            emoji: emoji,
            title: title,
            farmerName: farmerName,
            farmerPhone: farmerPhone,
            farmerPhotoUrl: farmerPhotoUrl,
            farmerDistrict: farmerDistrict,
            farmerVerified: farmerVerified,
            location: location,
            quantity: qty,
            remainingQuantity: remQty,
            unit: unit,
            unitLabel: rawUnit,
            pricePerUnit: price,
            minPrice: minPrice,
            qualityGrade: qualityGrade,
            category: category,
            harvestDate: harvestDate,
            availableDate: availableDate,
            description: description,
            imageUrls: imageUrls,
            videoUrl: videoUrl,
            videoNote: videoNote,
            isApproved: isApproved,
            status: status,
            createdAt: p['created_at']?.toString() ?? '',
          ));
        }

        if (loaded.isNotEmpty) {
          _products = loaded;
        }
      }
    } catch (e) {
      debugPrint('⚠️ [ADMIN REPO] Error fetching products: $e');
    } finally {
      _isLoadingProducts = false;
      notifyListeners();
    }
  }

  Future<void> fetchDemandsFromBackend() async {
    try {
      final data = await AdminApiService.fetchAllDemands();
      if (data.isNotEmpty) {
        final List<AdminDemandMonitoringRecord> loaded = [];
        for (var d in data) {
          final id = d['id']?.toString() ?? '';
          final title = d['product_title']?.toString() ?? '';
          final buyerStore = d['buyer_store']?.toString() ?? d['buyer_name']?.toString() ?? 'ক্রেতা';
          final buyerName = d['buyer_name']?.toString() ?? '';
          final buyerPhone = d['buyer_phone']?.toString() ?? '';
          final deliveryLocation = d['required_location']?.toString() ?? 'বাংলাদেশ';
          final qty = (d['quantity'] is num) ? (d['quantity'] as num).toDouble() : 0.0;
          final rawUnit = d['unit']?.toString() ?? 'কেজি';
          ProductUnit unit = ProductUnit.kg;
          if (rawUnit.contains('মন')) {
            unit = ProductUnit.mon;
          } else if (rawUnit.contains('টন')) {
            unit = ProductUnit.ton;
          }

          final budgetMin = d['target_price_min']?.toString() ?? '';
          final budgetMax = d['target_price_max']?.toString() ?? '';
          final budgetRange = (budgetMin.isNotEmpty && budgetMax.isNotEmpty)
              ? '৳$budgetMin - ৳$budgetMax / $rawUnit'
              : (budgetMax.isNotEmpty ? '৳$budgetMax / $rawUnit' : 'আলোচনা সাপেক্ষে');

          final offersCount = (d['offers_count'] is num) ? (d['offers_count'] as num).toInt() : 0;
          final status = (d['status'] ?? 'active').toString();
          final category = d['category']?.toString() ?? 'শাকসবজি';
          final description = d['description']?.toString() ?? '';
          final deadlineDate = d['deadline_date']?.toString() ?? '';

          String emoji = '📦';
          if (category.contains('সবজি')) {
            emoji = '🥦';
          } else if (category.contains('ফল')) {
            emoji = '🍎';
          } else if (title.contains('পেঁয়াজ')) {
            emoji = '🧅';
          } else if (title.contains('আলু')) {
            emoji = '🥔';
          }

          loaded.add(AdminDemandMonitoringRecord(
            id: id,
            emoji: emoji,
            title: title,
            buyerStore: buyerStore,
            buyerName: buyerName,
            buyerPhone: buyerPhone,
            deliveryLocation: deliveryLocation,
            requiredQuantity: qty,
            unit: unit,
            unitLabel: rawUnit,
            budgetRange: budgetRange,
            offersCount: offersCount,
            status: status == 'active' ? 'সক্রিয় (Active)' : status,
            category: category,
            description: description,
            deadlineDate: deadlineDate,
            createdAt: d['created_at']?.toString() ?? '',
          ));
        }

        if (loaded.isNotEmpty) {
          _demands = loaded;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('⚠️ [ADMIN REPO] Error fetching demands: $e');
    }
  }

  Future<bool> approveProduct(String productId) async {
    final idx = _products.indexWhere((p) => p.id == productId);
    if (idx != -1) {
      final old = _products[idx];
      _products[idx] = AdminProductApprovalRecord(
        id: old.id,
        farmerId: old.farmerId,
        emoji: old.emoji,
        title: old.title,
        farmerName: old.farmerName,
        farmerPhone: old.farmerPhone,
        farmerPhotoUrl: old.farmerPhotoUrl,
        farmerDistrict: old.farmerDistrict,
        farmerVerified: old.farmerVerified,
        location: old.location,
        quantity: old.quantity,
        remainingQuantity: old.remainingQuantity,
        unit: old.unit,
        unitLabel: old.unitLabel,
        pricePerUnit: old.pricePerUnit,
        minPrice: old.minPrice,
        qualityGrade: old.qualityGrade,
        category: old.category,
        harvestDate: old.harvestDate,
        availableDate: old.availableDate,
        description: old.description,
        imageUrls: old.imageUrls,
        videoUrl: old.videoUrl,
        videoNote: old.videoNote,
        isApproved: true,
        status: 'active',
        createdAt: old.createdAt,
      );
      if (activeProductForDetail?.id == productId) {
        activeProductForDetail = _products[idx];
      }
      notifyListeners();
    }
    return await AdminApiService.updateProductStatus(productId: productId, status: 'active');
  }

  Future<bool> rejectProduct(String productId) async {
    final idx = _products.indexWhere((p) => p.id == productId);
    if (idx != -1) {
      final old = _products[idx];
      _products[idx] = AdminProductApprovalRecord(
        id: old.id,
        farmerId: old.farmerId,
        emoji: old.emoji,
        title: old.title,
        farmerName: old.farmerName,
        farmerPhone: old.farmerPhone,
        farmerPhotoUrl: old.farmerPhotoUrl,
        farmerDistrict: old.farmerDistrict,
        farmerVerified: old.farmerVerified,
        location: old.location,
        quantity: old.quantity,
        remainingQuantity: old.remainingQuantity,
        unit: old.unit,
        unitLabel: old.unitLabel,
        pricePerUnit: old.pricePerUnit,
        minPrice: old.minPrice,
        qualityGrade: old.qualityGrade,
        category: old.category,
        harvestDate: old.harvestDate,
        availableDate: old.availableDate,
        description: old.description,
        imageUrls: old.imageUrls,
        videoUrl: old.videoUrl,
        videoNote: old.videoNote,
        isApproved: false,
        status: 'rejected',
        createdAt: old.createdAt,
      );
      if (activeProductForDetail?.id == productId) {
        activeProductForDetail = _products[idx];
      }
      notifyListeners();
    }
    return await AdminApiService.updateProductStatus(productId: productId, status: 'rejected');
  }

  Future<bool> deleteProductListing(String productId) async {
    _products.removeWhere((p) => p.id == productId);
    if (activeProductForDetail?.id == productId) {
      activeProductForDetail = null;
    }
    notifyListeners();
    return await AdminApiService.deleteProduct(productId);
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
        farmerId: 'f1',
        emoji: '🥔',
        title: 'টাটকা ডায়মন্ড লাল আলু (গ্রেড A)',
        farmerName: 'মো: আব্দুল রহিম',
        farmerPhone: '01709-122333',
        farmerPhotoUrl: 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?auto=format&fit=crop&w=600&q=80',
        farmerDistrict: 'রাজশাহী',
        farmerVerified: true,
        location: 'গোদাগাড়ী, রাজশাহী',
        quantity: 5000,
        remainingQuantity: 4200,
        unit: ProductUnit.kg,
        unitLabel: 'কেজি',
        pricePerUnit: 28,
        minPrice: 26,
        qualityGrade: 'A+ (প্রিমিয়াম মান)',
        category: 'শাকসবজি',
        harvestDate: '10-09-2026',
        availableDate: '12-09-2026',
        description: 'রাজশাহীর উর্বর মাটির টাটকা ডায়মন্ড লাল আলু। কোনো ধরনের রাসায়নিক বা প্রিজারভেটিভ ছাড়া প্রাকৃতিক উপায়ে উৎপাদিত। পাইকারি বাজারের জন্য উপযুক্ত গ্রেডিং করা।',
        imageUrls: [
          'https://images.unsplash.com/photo-1518977676601-b53f82aba655?auto=format&fit=crop&w=800&q=80',
          'https://images.unsplash.com/photo-1508747703725-719777637510?auto=format&fit=crop&w=800&q=80',
        ],
        videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
        videoNote: 'আলু তোলার সময় সরাসরি ক্ষেত থেকে ধারণকৃত ভিডিও',
        isApproved: true,
        status: 'active',
        createdAt: '2026-09-08 14:30',
      ),
      AdminProductApprovalRecord(
        id: 'p2',
        farmerId: 'f2',
        emoji: '🍅',
        title: 'দেশি পাকা টমেটো (১০০০ কেজি)',
        farmerName: 'খলিলুর রহমান',
        farmerPhone: '01892-120934',
        farmerPhotoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=600&q=80',
        farmerDistrict: 'দিনাজপুর',
        farmerVerified: true,
        location: 'বীরগঞ্জ, দিনাজপুর',
        quantity: 1000,
        remainingQuantity: 1000,
        unit: ProductUnit.kg,
        unitLabel: 'কেজি',
        pricePerUnit: 40,
        minPrice: 38,
        qualityGrade: 'Grade A',
        category: 'ফলমূল',
        harvestDate: '15-09-2026',
        availableDate: '16-09-2026',
        description: 'গাছে পাকা সুস্বাদু ও রসালো দেশি টমেটো। রান্নার জন্য কিংবা সসের জন্য পারফেক্ট। কোনো কৃত্রিম কার্বাইড বা বিষমুক্ত উপায়ে চাষ করা।',
        imageUrls: [
          'https://images.unsplash.com/photo-1546470427-e26264be0b11?auto=format&fit=crop&w=800&q=80',
          'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=800&q=80',
        ],
        videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
        videoNote: 'টমেটো ক্ষেতের তাজা ভিডিও দৃশ্য',
        isApproved: false,
        status: 'pending',
        createdAt: '2026-09-09 10:15',
      ),
    ];

    _demands = [
      AdminDemandMonitoringRecord(
        id: 'd1',
        emoji: '🧅',
        title: 'দেশি গোল পেঁয়াজ (জরুরি প্রয়োজন)',
        buyerStore: 'মেসার্স সততা এগ্রো ট্রেডার্স',
        buyerName: 'আলহাজ্ব শফিকুল ইসলাম',
        buyerPhone: '01911-543210',
        deliveryLocation: 'কারওয়ান বাজার, ঢাকা',
        requiredQuantity: 3000,
        unit: ProductUnit.kg,
        unitLabel: 'কেজি',
        budgetRange: '৳৬৫ - ৳৭২ / কেজি',
        offersCount: 3,
        status: 'সক্রিয় (Active)',
        category: 'মসলা',
        description: 'সরাসরি কৃষক ভাইদের কাছ থেকে শুকনো, ভালো মানের গোল দেশি পেঁয়াজ প্রয়োজন। ডেলিভারি স্পট কারওয়ান বাজার আড়ত। নগদ পেমেন্ট করা হবে।',
        deadlineDate: '20-09-2026',
        createdAt: '2026-09-08 11:00',
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
      photoUrl: farmer.photoUrl,
      krishiCardDocUrl: farmer.krishiCardDocUrl,
      adminNotes: farmer.adminNotes,
      nidStatus: farmer.nidStatus,
      nidRejectionNote: farmer.nidRejectionNote,
      productsCount: farmer.productsCount,
      offersCount: farmer.offersCount,
      activeOrdersCount: farmer.activeOrdersCount,
      completedOrders: farmer.completedOrders,
      totalEarnings: farmer.totalEarnings,
      rating: farmer.rating,
      reviewsCount: farmer.reviewsCount,
    );
    notifyListeners();
  }

  void openFarmerDetailFromProduct(AdminProductApprovalRecord product) {
    closeProductDetail();

    final matching = _farmers.cast<FarmerVerificationRecord?>().firstWhere(
      (f) => f != null && (
        (product.farmerId.isNotEmpty && f.id == product.farmerId) ||
        f.name.trim().toLowerCase() == product.farmerName.trim().toLowerCase() ||
        (product.farmerPhone.isNotEmpty && f.phone.replaceAll(RegExp(r'\D'), '') == product.farmerPhone.replaceAll(RegExp(r'\D'), ''))
      ),
      orElse: () => null,
    );

    final farmerProductsCount = _products.where((p) =>
      p.farmerId == product.farmerId ||
      p.farmerName.trim().toLowerCase() == product.farmerName.trim().toLowerCase() ||
      (product.farmerPhone.isNotEmpty && p.farmerPhone.replaceAll(RegExp(r'\D'), '') == product.farmerPhone.replaceAll(RegExp(r'\D'), ''))
    ).length;

    final photo = (matching?.photoUrl != null && matching!.photoUrl!.isNotEmpty)
        ? matching.photoUrl
        : product.farmerPhotoUrl;

    if (matching != null) {
      activeUserForDetail = UserDetailRecord(
        id: matching.id,
        name: matching.name,
        phone: matching.phone.isNotEmpty ? matching.phone : product.farmerPhone,
        email: matching.email,
        nid: matching.nid,
        location: matching.location.isNotEmpty ? matching.location : product.location,
        role: UserRole.farmer,
        status: matching.status,
        farmerType: matching.farmerType,
        nidFrontUrl: matching.nidFrontUrl,
        nidBackUrl: matching.nidBackUrl,
        photoUrl: photo,
        krishiCardDocUrl: matching.krishiCardDocUrl,
        adminNotes: matching.adminNotes,
        nidStatus: matching.nidStatus,
        nidRejectionNote: matching.nidRejectionNote,
        productsCount: farmerProductsCount > matching.productsCount ? farmerProductsCount : matching.productsCount,
        offersCount: matching.offersCount,
        activeOrdersCount: matching.activeOrdersCount,
        completedOrders: matching.completedOrders,
        totalEarnings: matching.totalEarnings,
        rating: matching.rating,
        reviewsCount: matching.reviewsCount,
      );
    } else {
      activeUserForDetail = UserDetailRecord(
        id: product.farmerId.isNotEmpty ? product.farmerId : 'farmer_${product.id}',
        name: product.farmerName,
        phone: product.farmerPhone,
        email: '',
        nid: 'যাচাই করা হয়নি',
        location: product.location,
        role: UserRole.farmer,
        status: product.farmerVerified ? VerificationStatus.verified : VerificationStatus.pending,
        nidFrontUrl: '',
        nidBackUrl: '',
        photoUrl: photo,
        productsCount: farmerProductsCount,
      );
    }
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
      photoUrl: buyer.photoUrl,
      adminNotes: buyer.adminNotes,
      nidStatus: buyer.nidStatus,
      nidRejectionNote: buyer.nidRejectionNote,
      productsCount: buyer.productsCount,
      offersCount: buyer.offersCount,
      activeOrdersCount: buyer.activeOrdersCount,
      completedOrders: buyer.completedOrders,
      totalEarnings: buyer.totalEarnings,
      rating: buyer.rating,
      reviewsCount: buyer.reviewsCount,
    );
    notifyListeners();
  }

  void closeUserDetail() {
    activeUserForDetail = null;
    notifyListeners();
  }

  Future<void> updateUserStatus({
    required String userId,
    required VerificationStatus status,
    required String adminNote,
  }) async {
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
        photoUrl: activeUserForDetail!.photoUrl,
        krishiCardDocUrl: activeUserForDetail!.krishiCardDocUrl,
        adminNotes: adminNote,
        nidStatus: activeUserForDetail!.nidStatus,
        nidRejectionNote: activeUserForDetail!.nidRejectionNote,
        productsCount: activeUserForDetail!.productsCount,
        offersCount: activeUserForDetail!.offersCount,
        activeOrdersCount: activeUserForDetail!.activeOrdersCount,
        completedOrders: activeUserForDetail!.completedOrders,
        totalEarnings: activeUserForDetail!.totalEarnings,
        rating: activeUserForDetail!.rating,
        reviewsCount: activeUserForDetail!.reviewsCount,
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
        photoUrl: _farmers[fIdx].photoUrl,
        krishiCardDocUrl: _farmers[fIdx].krishiCardDocUrl,
        adminNotes: adminNote,
        nidStatus: _farmers[fIdx].nidStatus,
        nidRejectionNote: _farmers[fIdx].nidRejectionNote,
        productsCount: _farmers[fIdx].productsCount,
        offersCount: _farmers[fIdx].offersCount,
        activeOrdersCount: _farmers[fIdx].activeOrdersCount,
        totalEarnings: _farmers[fIdx].totalEarnings,
        rating: _farmers[fIdx].rating,
        reviewsCount: _farmers[fIdx].reviewsCount,
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
        businessLicenseNo: _buyers[bIdx].businessLicenseNo,
        photoUrl: _buyers[bIdx].photoUrl,
        adminNotes: adminNote,
        nidStatus: _buyers[bIdx].nidStatus,
        nidRejectionNote: _buyers[bIdx].nidRejectionNote,
        productsCount: _buyers[bIdx].productsCount,
        offersCount: _buyers[bIdx].offersCount,
        activeOrdersCount: _buyers[bIdx].activeOrdersCount,
        totalEarnings: _buyers[bIdx].totalEarnings,
        rating: _buyers[bIdx].rating,
        reviewsCount: _buyers[bIdx].reviewsCount,
      );
    }

    notifyListeners();


    // Persist to backend database
    String statusStr = 'pending';
    if (status == VerificationStatus.verified) statusStr = 'verified';
    if (status == VerificationStatus.inProgress) statusStr = 'inprogress';
    if (status == VerificationStatus.rejected) statusStr = 'rejected';
    if (status == VerificationStatus.suspended) statusStr = 'suspended';

    await AdminApiService.updateUserStatus(
      userId: userId,
      status: statusStr,
      adminNote: adminNote,
    );
  }

  Future<void> updateNidStatus({
    required String userId,
    required VerificationStatus nidStatus,
    required String rejectionReason,
  }) async {
    String nidStatusStr = 'pending';
    if (nidStatus == VerificationStatus.verified) nidStatusStr = 'verified';
    if (nidStatus == VerificationStatus.rejected) nidStatusStr = 'rejected';

    if (activeUserForDetail?.id == userId) {
      activeUserForDetail = UserDetailRecord(
        id: activeUserForDetail!.id,
        name: activeUserForDetail!.name,
        phone: activeUserForDetail!.phone,
        email: activeUserForDetail!.email,
        nid: activeUserForDetail!.nid,
        location: activeUserForDetail!.location,
        role: activeUserForDetail!.role,
        status: activeUserForDetail!.status,
        farmerType: activeUserForDetail!.farmerType,
        storeName: activeUserForDetail!.storeName,
        tradeLicenseNo: activeUserForDetail!.tradeLicenseNo,
        businessLicenseNo: activeUserForDetail!.businessLicenseNo,
        nidFrontUrl: activeUserForDetail!.nidFrontUrl,
        nidBackUrl: activeUserForDetail!.nidBackUrl,
        tradeLicenseUrl: activeUserForDetail!.tradeLicenseUrl,
        photoUrl: activeUserForDetail!.photoUrl,
        krishiCardDocUrl: activeUserForDetail!.krishiCardDocUrl,
        adminNotes: rejectionReason.isNotEmpty ? rejectionReason : activeUserForDetail!.adminNotes,
        nidStatus: nidStatus,
        nidRejectionNote: rejectionReason,
        productsCount: activeUserForDetail!.productsCount,
        offersCount: activeUserForDetail!.offersCount,
        activeOrdersCount: activeUserForDetail!.activeOrdersCount,
        completedOrders: activeUserForDetail!.completedOrders,
        totalEarnings: activeUserForDetail!.totalEarnings,
        rating: activeUserForDetail!.rating,
        reviewsCount: activeUserForDetail!.reviewsCount,
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
        status: _farmers[fIdx].status,
        nidFrontUrl: _farmers[fIdx].nidFrontUrl,
        nidBackUrl: _farmers[fIdx].nidBackUrl,
        photoUrl: _farmers[fIdx].photoUrl,
        krishiCardDocUrl: _farmers[fIdx].krishiCardDocUrl,
        adminNotes: rejectionReason.isNotEmpty ? rejectionReason : _farmers[fIdx].adminNotes,
        nidStatus: nidStatus,
        nidRejectionNote: rejectionReason,
        productsCount: _farmers[fIdx].productsCount,
        offersCount: _farmers[fIdx].offersCount,
        activeOrdersCount: _farmers[fIdx].activeOrdersCount,
        completedOrders: _farmers[fIdx].completedOrders,
        totalEarnings: _farmers[fIdx].totalEarnings,
        rating: _farmers[fIdx].rating,
        reviewsCount: _farmers[fIdx].reviewsCount,
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
        status: _buyers[bIdx].status,
        nidFrontUrl: _buyers[bIdx].nidFrontUrl,
        nidBackUrl: _buyers[bIdx].nidBackUrl,
        tradeLicenseUrl: _buyers[bIdx].tradeLicenseUrl,
        businessLicenseNo: _buyers[bIdx].businessLicenseNo,
        photoUrl: _buyers[bIdx].photoUrl,
        adminNotes: rejectionReason.isNotEmpty ? rejectionReason : _buyers[bIdx].adminNotes,
        nidStatus: nidStatus,
        nidRejectionNote: rejectionReason,
        productsCount: _buyers[bIdx].productsCount,
        offersCount: _buyers[bIdx].offersCount,
        activeOrdersCount: _buyers[bIdx].activeOrdersCount,
        completedOrders: _buyers[bIdx].completedOrders,
        totalEarnings: _buyers[bIdx].totalEarnings,
        rating: _buyers[bIdx].rating,
        reviewsCount: _buyers[bIdx].reviewsCount,
      );
    }

    notifyListeners();

    await AdminApiService.updateUserStatus(
      userId: userId,
      nidStatus: nidStatusStr,
      nidRejectionNote: rejectionReason,
      adminNote: rejectionReason.isNotEmpty ? rejectionReason : null,
    );
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
}
