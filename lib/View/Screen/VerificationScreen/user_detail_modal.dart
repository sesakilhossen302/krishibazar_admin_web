import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../Core/Network/admin_api_service.dart';
import '../../../global/Model/admin_models.dart';
import '../../../global/controller/admin_repository.dart';

class UserDetailModal extends StatefulWidget {
  final UserDetailRecord user;

  const UserDetailModal({super.key, required this.user});

  @override
  State<UserDetailModal> createState() => _UserDetailModalState();
}

class _UserDetailModalState extends State<UserDetailModal> {
  late final TextEditingController _noteController;
  VerificationStatus? _selectedStatusToUpdate;
  bool _isUpdatingStatus = false;

  List<String> _getQuickNotesForStatus(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.verified:
        return [
          'সকল তথ্য ও কাগজপত্র সঠিক রয়েছে এবং ভেরিফাইড',
          'অ্যাকাউন্ট সফলভাবে যাচাই ও সক্রিয় করা হলো',
          'অভিনন্দন! আপনার ভেরিফিকেশন সফল হয়েছে',
        ];
      case VerificationStatus.inProgress:
        return [
          'আপনার কাগজপত্র যাচাই প্রক্রিয়া চলছে',
          'জাতীয় পরিচয়পত্র ও তথ্যাদি পর্যালোচনায় রয়েছে',
          'খুব শীঘ্রই পর্যালোচনার ফলাফল জানানো হবে',
        ];
      case VerificationStatus.pending:
        return [
          'অ্যাকাউন্ট ভেরিফিকেশন পর্যালোচনার তালিকায় রয়েছে',
          'প্রয়োজনীয় তথ্যাদি পর্যালোচনার অপেক্ষায়',
        ];
      case VerificationStatus.suspended:
        return [
          'সন্দেহজনক কার্যক্রমের কারণে সাময়িক স্থগিত',
          'নীতিমালা লঙ্ঘনের অভিযোগে অ্যাকাউন্ট স্থগিত রাখা হলো',
          'বিস্তারিত তথ্যের জন্য সাপোর্টে যোগাযোগ করুন',
        ];
      case VerificationStatus.rejected:
        return [
          'এনআইডি কার্ডের ছবি অস্পষ্ট, পরিষ্কার ছবি পুনরায় দিন',
          'নাম ও তথ্যের সাথে এনআইডি কার্ডের অমিল রয়েছে',
          'এনআইডি কার্ডের উভয় পাশের ছবি আপলোড করুন',
          'প্রদত্ত ট্রেড লাইসেন্স বা কৃষি কার্ডের মেয়াদ শেষ',
          'জাল বা অসম্পূর্ণ কাগজপত্র পাওয়ার কারণে বাতিল',
        ];
    }
  }

  void _selectStatusForUpdate(VerificationStatus status) {
    setState(() {
      _selectedStatusToUpdate = status;
      final notes = _getQuickNotesForStatus(status);
      if (notes.isNotEmpty) {
        _noteController.text = notes.first;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(
      text: widget.user.nidRejectionNote.isNotEmpty
          ? widget.user.nidRejectionNote
          : widget.user.adminNotes,
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();

  }

  void _openImagePreview(BuildContext context, String title, String imgUrl) {
    if (imgUrl.isEmpty) return;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 960,
            maxHeight: MediaQuery.of(context).size.height * 0.88,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 30,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dialog Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: const BoxDecoration(
                  color: Color(0xFF0F172A),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.zoom_in_rounded, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                      tooltip: 'বন্ধ করুন',
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              ),

              // Interactive Image Viewer
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  child: Container(
                    color: const Color(0xFF090D16),
                    child: InteractiveViewer(
                      panEnabled: true,
                      boundaryMargin: const EdgeInsets.all(30),
                      minScale: 0.8,
                      maxScale: 4.5,
                      child: Center(
                        child: Image.network(
                          imgUrl,
                          fit: BoxFit.contain,
                          loadingBuilder: (ctx, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(color: Colors.white),
                            );
                          },
                          errorBuilder: (c, e, s) => const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.broken_image_rounded, color: Colors.white38, size: 64),
                                SizedBox(height: 12),
                                Text(
                                  'ছবি লোড করা সম্ভব হয়নি',
                                  style: TextStyle(color: Colors.white70, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label কপি করা হয়েছে: $text'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AdminRepository>();
    final isBuyer = widget.user.role == UserRole.buyer;

    return Container(
      color: Colors.black.withValues(alpha: 0.65),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 750,
              maxHeight: MediaQuery.of(context).size.height * 0.94,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 32,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Modern Header Banner
                  _buildHeader(isBuyer, repo),

                  // Scrollable Content Body
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Contact & Identity Grid (Phone, Email, NID, Status)
                          _buildContactAndIdentityGrid(isBuyer),

                          const SizedBox(height: 16),

                          // 1.1 User Live Activity Stats (Products, Offers, Orders, Earnings, Rating, Reviews)
                          _buildUserActivityStatsSection(isBuyer, repo),

                          const SizedBox(height: 16),

                          // 2. Location / Address Section (Card style with multiline wrap)
                          _buildLocationSection(),


                          const SizedBox(height: 16),

                          // 3. Farm or Business Specifics Section
                          if (isBuyer)
                            _buildBuyerDetailsSection()
                          else
                            _buildFarmerDetailsSection(),

                          const SizedBox(height: 24),

                          // 3.1 All Listed Products by this Farmer
                          _buildUserProductsSection(repo),

                          const SizedBox(height: 24),

                          // 4. Dedicated NID Verification & Document Section
                          _buildNidVerificationSection(repo),

                          const SizedBox(height: 20),

                          // 5. Additional Uploaded Documents (Krishi Card / Trade License)
                          _buildOtherDocumentsSection(isBuyer),

                          const SizedBox(height: 24),

                          // 6. Overall Account Verification Decision Bar & Interactive Note Flow
                          _buildAccountActionButtons(repo),

                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // HEADER BANNER
  Widget _buildHeader(bool isBuyer, AdminRepository repo) {
    final status = widget.user.status;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile Photo / Avatar
          Stack(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isBuyer ? const Color(0xFFD97706) : const Color(0xFF16A34A),
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: (widget.user.photoUrl != null && widget.user.photoUrl!.isNotEmpty)
                      ? Image.network(
                          AdminApiService.formatMediaUrl(widget.user.photoUrl!),
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => _buildAvatarFallback(isBuyer),
                        )
                      : _buildAvatarFallback(isBuyer),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.circle, size: 8, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),

          // User Name & Role Badges
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.user.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '#${widget.user.id}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Role Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: isBuyer ? const Color(0xFFFEF3C7) : const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isBuyer ? const Color(0xFFFDE68A) : const Color(0xFFBBF7D0),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isBuyer ? Icons.storefront_rounded : Icons.agriculture_rounded,
                            size: 14,
                            color: isBuyer ? const Color(0xFFB45309) : const Color(0xFF15803D),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isBuyer ? 'পাইকারি ক্রেতা / আড়তদার' : 'কৃষক / উৎপাদনকারী',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isBuyer ? const Color(0xFFB45309) : const Color(0xFF15803D),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Status Badge
                    _buildStatusBadge(status),
                  ],
                ),
              ],
            ),
          ),

          // Close Modal Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: IconButton(
              icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 20),
              tooltip: 'বন্ধ করুন',
              onPressed: () => repo.closeUserDetail(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback(bool isBuyer) {
    final name = widget.user.name.trim();
    if (name.isNotEmpty && name != 'অজ্ঞাত') {
      final initial = name.characters.first.toUpperCase();
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isBuyer
                ? [const Color(0xFFD97706), const Color(0xFFF59E0B)]
                : [const Color(0xFF166534), const Color(0xFF22C55E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Text(
            initial,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );
    }
    return Container(
      color: isBuyer ? const Color(0xFFFEF3C7) : const Color(0xFFDCFCE7),
      child: Center(
        child: Icon(
          isBuyer ? Icons.storefront_rounded : Icons.person_rounded,
          color: isBuyer ? const Color(0xFFB45309) : const Color(0xFF15803D),
          size: 28,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(VerificationStatus status) {
    Color bg;
    Color fg;
    IconData icon;

    switch (status) {
      case VerificationStatus.verified:
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF15803D);
        icon = Icons.verified_rounded;
        break;
      case VerificationStatus.inProgress:
        bg = const Color(0xFFE0F2FE);
        fg = const Color(0xFF0369A1);
        icon = Icons.autorenew_rounded;
        break;
      case VerificationStatus.pending:
        bg = const Color(0xFFFFEDD5);
        fg = const Color(0xFFC2410C);
        icon = Icons.hourglass_top_rounded;
        break;
      case VerificationStatus.suspended:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFB91C1C);
        icon = Icons.block_rounded;
        break;
      case VerificationStatus.rejected:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFDC2626);
        icon = Icons.cancel_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 5),
          Text(
            status.labelBn,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.verified:
        return const Color(0xFF16A34A);
      case VerificationStatus.inProgress:
        return const Color(0xFF0284C7);
      case VerificationStatus.pending:
        return const Color(0xFFEA580C);
      case VerificationStatus.suspended:
      case VerificationStatus.rejected:
        return const Color(0xFFDC2626);
    }
  }

  // 1. CONTACT & IDENTITY GRID (2-COLUMN CARDS / RESPONSIVE)
  Widget _buildContactAndIdentityGrid(bool isBuyer) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 480;

        if (isNarrow) {
          return Column(
            children: [
              _buildDetailTile(
                icon: Icons.phone_android_rounded,
                iconColor: const Color(0xFF0284C7),
                label: 'ফোন নম্বর',
                value: widget.user.phone.isNotEmpty ? widget.user.phone : 'দেওয়া নেই',
                canCopy: widget.user.phone.isNotEmpty,
              ),
              const SizedBox(height: 10),
              _buildDetailTile(
                icon: Icons.alternate_email_rounded,
                iconColor: const Color(0xFF7C3AED),
                label: 'ইমেইল ঠিকানা',
                value: widget.user.email.isNotEmpty ? widget.user.email : 'দেওয়া নেই',
                canCopy: widget.user.email.isNotEmpty,
              ),
              const SizedBox(height: 10),
              _buildDetailTile(
                icon: Icons.badge_rounded,
                iconColor: const Color(0xFF059669),
                label: 'এনআইডি (NID) নম্বর',
                value: (widget.user.nid.isNotEmpty && widget.user.nid != 'NID নেই')
                    ? widget.user.nid
                    : 'NID নম্বর দেওয়া হয়নি',
                canCopy: widget.user.nid.isNotEmpty && widget.user.nid != 'NID নেই',
              ),
              const SizedBox(height: 10),
              _buildDetailTile(
                icon: Icons.security_rounded,
                iconColor: const Color(0xFFD97706),
                label: 'অ্যাকাউন্ট অবস্থা',
                value: widget.user.status.labelBn,
                highlightColor: _getStatusColor(widget.user.status),
              ),
            ],
          );
        }

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildDetailTile(
                    icon: Icons.phone_android_rounded,
                    iconColor: const Color(0xFF0284C7),
                    label: 'ফোন নম্বর',
                    value: widget.user.phone.isNotEmpty ? widget.user.phone : 'দেওয়া নেই',
                    canCopy: widget.user.phone.isNotEmpty,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDetailTile(
                    icon: Icons.alternate_email_rounded,
                    iconColor: const Color(0xFF7C3AED),
                    label: 'ইমেইল ঠিকানা',
                    value: widget.user.email.isNotEmpty ? widget.user.email : 'দেওয়া নেই',
                    canCopy: widget.user.email.isNotEmpty,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDetailTile(
                    icon: Icons.badge_rounded,
                    iconColor: const Color(0xFF059669),
                    label: 'এনআইডি (NID) নম্বর',
                    value: (widget.user.nid.isNotEmpty && widget.user.nid != 'NID নেই')
                        ? widget.user.nid
                        : 'NID নম্বর দেওয়া হয়নি',
                    canCopy: widget.user.nid.isNotEmpty && widget.user.nid != 'NID নেই',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDetailTile(
                    icon: Icons.security_rounded,
                    iconColor: const Color(0xFFD97706),
                    label: 'অ্যাকাউন্ট অবস্থা',
                    value: widget.user.status.labelBn,
                    highlightColor: _getStatusColor(widget.user.status),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // 1.1 USER LIVE ACTIVITY & STATS SECTION
  Widget _buildUserActivityStatsSection(bool isBuyer, AdminRepository repo) {
    final matchingProducts = repo.products.where((p) =>
      p.farmerId == widget.user.id ||
      p.farmerName.trim().toLowerCase() == widget.user.name.trim().toLowerCase() ||
      (widget.user.phone.isNotEmpty && p.farmerPhone.replaceAll(RegExp(r'\D'), '') == widget.user.phone.replaceAll(RegExp(r'\D'), ''))
    ).toList();
    final productsCount = isBuyer
        ? widget.user.productsCount
        : (matchingProducts.length > widget.user.productsCount ? matchingProducts.length : widget.user.productsCount);
    final offersCount = widget.user.offersCount;
    final activeOrders = widget.user.activeOrdersCount;
    final completedOrders = widget.user.completedOrders;
    final earnings = widget.user.totalEarnings;
    final rating = widget.user.rating;
    final reviews = widget.user.reviewsCount;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF166534).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.analytics_rounded, size: 18, color: Color(0xFF166534)),
              ),
              const SizedBox(width: 8),
              Text(
                isBuyer ? 'ব্যবহারকারীর ব্যবসায়িক কার্যকলাপ ও অর্ডার পরিসংখ্যান' : 'ব্যবহারকারীর খামার কার্যকলাপ ও বিক্রি পরিসংখ্যান',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildStatPill(
                icon: isBuyer ? Icons.campaign_rounded : Icons.inventory_2_rounded,
                iconColor: const Color(0xFF166534),
                bgColor: const Color(0xFFDCFCE7),
                title: isBuyer ? 'মোট চাহিদা' : 'মোট পণ্য',
                value: '$productsCount টি',
              ),
              if (isBuyer)
                _buildStatPill(
                  icon: Icons.local_offer_rounded,
                  iconColor: const Color(0xFFEA580C),
                  bgColor: const Color(0xFFFFEDD5),
                  title: 'প্রাপ্ত অফারসমূহ',
                  value: '$offersCount টি',
                )
              else
                _buildStatPill(
                  icon: Icons.check_circle_rounded,
                  iconColor: const Color(0xFF059669),
                  bgColor: const Color(0xFFD1FAE5),
                  title: 'সম্পন্ন অর্ডার',
                  value: '$completedOrders টি',
                ),
              _buildStatPill(
                icon: Icons.local_shipping_rounded,
                iconColor: const Color(0xFF2563EB),
                bgColor: const Color(0xFFDBEAFE),
                title: 'চলমান অর্ডার',
                value: '$activeOrders টি',
              ),
              _buildStatPill(
                icon: Icons.account_balance_wallet_rounded,
                iconColor: const Color(0xFF7E22CE),
                bgColor: const Color(0xFFF3E8FF),
                title: isBuyer ? 'মোট ক্রয়/লেনদেন' : 'মোট আয়',
                value: '৳${earnings.toInt()}',
              ),
              _buildStatPill(
                icon: Icons.star_rounded,
                iconColor: const Color(0xFFD97706),
                bgColor: const Color(0xFFFEF3C7),
                title: 'রেটিং ও রিভিউ',
                value: rating > 0 ? '★ ${rating.toStringAsFixed(1)} ($reviews রিভিউ)' : '★ ০.০ (০ রিভিউ)',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String value,
  }) {
    return Container(
      constraints: const BoxConstraints(minWidth: 120),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildDetailTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    bool canCopy = false,
    Color? highlightColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 3),
                SelectableText(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: highlightColor ?? const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
          if (canCopy)
            InkWell(
              onTap: () => _copyToClipboard(value, label),
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(Icons.copy_rounded, size: 14, color: Colors.grey.shade500),
              ),
            ),
        ],
      ),
    );
  }

  // 2. LOCATION & ADDRESS SECTION
  Widget _buildLocationSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.location_on_rounded, size: 20, color: Color(0xFF15803D)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'এলাকা ও সম্পূর্ণ ঠিকানা',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF166534),
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  widget.user.location.isNotEmpty ? widget.user.location : 'ঠিকানা উল্লেখ নেই',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. FARMER DETAILS SECTION
  Widget _buildFarmerDetailsSection() {
    final farmerType = widget.user.farmerType ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF15803D).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.eco_rounded, size: 20, color: Color(0xFF15803D)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'চাষের বিবরণ ও ফসল (Farming & Crops)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  farmerType.isNotEmpty ? farmerType : 'সাধারণ কৃষক / বিবরণ পাওয়া যায়নি',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 4. BUYER DETAILS SECTION
  Widget _buildBuyerDetailsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.store_rounded, size: 18, color: Color(0xFFB45309)),
              ),
              const SizedBox(width: 10),
              const Text(
                'ব্যবসা ও প্রতিষ্ঠানের প্রোফাইল',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB45309),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('দোকানের নাম:', style: TextStyle(fontSize: 11, color: Color(0xFF78350F))),
                    const SizedBox(height: 2),
                    SelectableText(
                      widget.user.storeName ?? 'উল্লেখ নেই',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ট্রেড লাইসেন্স:', style: TextStyle(fontSize: 11, color: Color(0xFF78350F))),
                    const SizedBox(height: 2),
                    SelectableText(
                      widget.user.tradeLicenseNo ?? 'দেওয়া নেই',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (widget.user.businessLicenseNo != null && widget.user.businessLicenseNo!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('ব্যবসার ধরন: ', style: TextStyle(fontSize: 11, color: Color(0xFF78350F))),
                Text(
                  widget.user.businessLicenseNo!,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _toBnDigits(num value) {
    const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bn = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    String s = value.toString();
    for (int i = 0; i < 10; i++) {
      s = s.replaceAll(en[i], bn[i]);
    }
    return s;
  }

  // 3.1 ALL LISTED PRODUCTS BY THIS FARMER / USER
  Widget _buildUserProductsSection(AdminRepository repo) {
    final isBuyer = widget.user.role == UserRole.buyer;

    if (isBuyer) {
      final userDemands = repo.demands.where((d) =>
        d.buyerName.trim().toLowerCase() == widget.user.name.trim().toLowerCase() ||
        (widget.user.phone.isNotEmpty && d.buyerPhone.replaceAll(RegExp(r'\D'), '') == widget.user.phone.replaceAll(RegExp(r'\D'), ''))
      ).toList();

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.campaign_rounded, size: 20, color: Color(0xFFB45309)),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'পাইকারের পোস্টকৃত ক্রয়ের চাহিদা',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFB45309),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'মোট ${_toBnDigits(userDemands.length)} টি চাহিদা',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'এই পাইকার কর্তৃক পোস্ট করা ক্রয়ের চাহিদা ও রিকোয়ারমেন্টসমূহ',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (userDemands.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Center(
                  child: Text(
                    'এই পাইকারের কোনো ক্রয়ের চাহিদা বর্তমানে নেই।',
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: userDemands.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final demand = userDemands[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Text(demand.emoji, style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                demand.title,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'প্রয়োজন: ${_toBnDigits(demand.requiredQuantity.toInt())} ${demand.unitLabel} • বাজেট: ${demand.budgetRange}',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => repo.openDemandDetail(demand),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0284C7),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            elevation: 0,
                          ),
                          child: const Text('বিস্তারিত', style: TextStyle(color: Colors.white, fontSize: 11)),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      );
    }

    // Farmer products list
    final userProducts = repo.products.where((p) =>
      p.farmerId == widget.user.id ||
      p.farmerName.trim().toLowerCase() == widget.user.name.trim().toLowerCase() ||
      (widget.user.phone.isNotEmpty && p.farmerPhone.replaceAll(RegExp(r'\D'), '') == widget.user.phone.replaceAll(RegExp(r'\D'), ''))
    ).toList();

    final activeCount = userProducts.where((p) => p.isApproved).length;
    final pendingCount = userProducts.where((p) => !p.isApproved).length;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title and Badges Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.agriculture_rounded,
                      size: 22,
                      color: Color(0xFF166534),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'কৃষকের সকল পণ্য লিস্টিং',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF166534),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'মোট ${_toBnDigits(userProducts.length)} টি পণ্য',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'এই কৃষকের খামারের উৎপাদিত ও অ্যাপে তালিকাভুক্ত সকল ফসলের তালিকা',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (userProducts.isNotEmpty)
                Row(
                  children: [
                    if (activeCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '✅ সক্রিয়: ${_toBnDigits(activeCount)} টি',
                          style: const TextStyle(
                            color: Color(0xFF166534),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (pendingCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEDD5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '⏳ অপেক্ষমাণ: ${_toBnDigits(pendingCount)} টি',
                          style: const TextStyle(
                            color: Color(0xFFEA580C),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Content
          if (userProducts.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Column(
                children: [
                  Icon(Icons.inventory_2_outlined, size: 40, color: Color(0xFF94A3B8)),
                  SizedBox(height: 10),
                  Text(
                    'এই কৃষকের কোনো পণ্য বর্তমানে তালিকায় পাওয়া যায়নি',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'কৃষক নতুন পণ্য লিস্টিং করলে তা এখানে স্বয়ংক্রিয়ভাবে প্রদর্শিত হবে',
                    style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: userProducts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final product = userProducts[index];
                return _buildProductListItemCard(product, repo);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildProductListItemCard(AdminProductApprovalRecord product, AdminRepository repo) {
    final hasImages = product.imageUrls.isNotEmpty;
    final primaryImage = hasImages ? AdminApiService.formatMediaUrl(product.imageUrls.first) : '';

    return InkWell(
      onTap: () => repo.openProductDetail(product),
      borderRadius: BorderRadius.circular(12),
      hoverColor: const Color(0xFFF0FDF4),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: product.isApproved ? const Color(0xFFE2E8F0) : const Color(0xFFFED7AA),
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Product Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 72,
                height: 72,
                color: Colors.white,
                child: primaryImage.isNotEmpty
                    ? Image.network(
                        primaryImage,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Center(
                          child: Text(product.emoji, style: const TextStyle(fontSize: 32)),
                        ),
                      )
                    : Center(
                        child: Text(product.emoji, style: const TextStyle(fontSize: 32)),
                      ),
              ),
            ),
            const SizedBox(width: 14),

            // Main Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          product.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.category,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF475569),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.qualityGrade,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF92400E),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.sell_outlined, size: 14, color: Color(0xFFEA580C)),
                          const SizedBox(width: 4),
                          Text(
                            '৳${_toBnDigits(product.pricePerUnit.toInt())} / ${product.unitLabel}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFEA580C),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.inventory_2_outlined, size: 14, color: Color(0xFF166534)),
                          const SizedBox(width: 4),
                          Text(
                            'মোট: ${_toBnDigits(product.quantity.toInt())} ${product.unitLabel} (অবশিষ্ট: ${_toBnDigits(product.remainingQuantity.toInt())} ${product.unitLabel})',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ],
                      ),
                      if (product.location.isNotEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF64748B)),
                            const SizedBox(width: 4),
                            Text(
                              product.location,
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 14),

            // Status & Action Button
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: product.isApproved ? const Color(0xFFDCFCE7) : const Color(0xFFFFEDD5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    product.isApproved ? 'সক্রিয় (Active)' : 'পর্যালোচনায় (Pending)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: product.isApproved ? const Color(0xFF166534) : const Color(0xFFEA580C),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => repo.openProductDetail(product),
                  icon: const Icon(Icons.visibility_outlined, size: 14, color: Colors.white),
                  label: const Text(
                    'পণ্য বিস্তারিত →',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF166534),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    elevation: 0,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 4. DEDICATED NID VERIFICATION & INSPECTION SECTION
  Widget _buildNidVerificationSection(AdminRepository repo) {
    final nidStatus = widget.user.nidStatus;
    final isNidVerified = nidStatus == VerificationStatus.verified;
    final isNidRejected = nidStatus == VerificationStatus.rejected;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isNidRejected
            ? const Color(0xFFFEF2F2)
            : isNidVerified
                ? const Color(0xFFF0FDF4)
                : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNidRejected
              ? const Color(0xFFFCA5A5)
              : isNidVerified
                  ? const Color(0xFF86EFAC)
                  : const Color(0xFFCBD5E1),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // NID Header and Live Status Chip
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isNidRejected
                      ? const Color(0xFFEF4444)
                      : isNidVerified
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF0284C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.badge_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'এনআইডি কার্ড যাচাই ও সিদ্ধান্ত (NID Verification)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'নাম, ছবির মিল ও তথ্যের সত্যতা যাচাই করে সিদ্ধান্ত নিন',
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              // NID Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isNidVerified
                      ? const Color(0xFFDCFCE7)
                      : isNidRejected
                          ? const Color(0xFFFEE2E2)
                          : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isNidVerified
                        ? const Color(0xFF86EFAC)
                        : isNidRejected
                            ? const Color(0xFFFCA5A5)
                            : const Color(0xFFFDE68A),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isNidVerified
                          ? Icons.check_circle_rounded
                          : isNidRejected
                              ? Icons.cancel_rounded
                              : Icons.hourglass_empty_rounded,
                      size: 13,
                      color: isNidVerified
                          ? const Color(0xFF15803D)
                          : isNidRejected
                              ? const Color(0xFFB91C1C)
                              : const Color(0xFFB45309),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isNidVerified
                          ? 'এনআইডি সঠিক ✅'
                          : isNidRejected
                              ? 'এনআইডি বাতিল ❌'
                              : 'এনআইডি অপেক্ষমাণ ⏳',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isNidVerified
                            ? const Color(0xFF15803D)
                            : isNidRejected
                                ? const Color(0xFFB91C1C)
                                : const Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (widget.user.adminNotes.contains('নতুন এনআইডি') || (widget.user.nidStatus == VerificationStatus.pending && (widget.user.nidFrontUrl.isNotEmpty || widget.user.nidBackUrl.isNotEmpty))) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF60A5FA), width: 1.5),
              ),
              child: const Row(
                children: [
                  Icon(Icons.mark_email_unread_rounded, size: 16, color: Color(0xFF2563EB)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '🔔 ইউজার নতুন এনআইডি কার্ড জমা দিয়েছেন (অনুমোদন বা পুনঃযাচাই প্রয়োজন)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E40AF),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (isNidRejected && widget.user.nidRejectionNote.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFFDC2626)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'পূর্ববর্তী বাতিলের কারণ: ${widget.user.nidRejectionNote}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF991B1B), fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),

          // NID Front and Back Photos
          Row(
            children: [
              Expanded(
                child: _buildModernDocCard(
                  title: 'এনআইডি (সামনের দিক)',
                  subtitle: 'NID Card Front',
                  imgUrl: widget.user.nidFrontUrl,
                  icon: Icons.credit_card_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildModernDocCard(
                  title: 'এনআইডি (পেছনের দিক)',
                  subtitle: 'NID Card Back',
                  imgUrl: widget.user.nidBackUrl,
                  icon: Icons.credit_card_rounded,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // NID Verification Decision Buttons
          Row(
            children: [
              // Approve NID Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await repo.updateNidStatus(
                      userId: widget.user.id,
                      nidStatus: VerificationStatus.verified,
                      rejectionReason: '',
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${widget.user.name} এর এনআইডি কার্ড অনুমোদিত ও সঠিক চিহ্নিত করা হয়েছে ✅'),
                          backgroundColor: const Color(0xFF15803D),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                  label: const Text('এনআইডি অনুমোদন করুন (NID Verified ✅)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF15803D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Reject NID Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    String reason = _noteController.text.trim();
                    if (reason.isEmpty) {
                      reason = 'এনআইডি কার্ডের ছবি অস্পষ্ট অথবা তথ্যের অমিল রয়েছে। অনুগ্রহ করে পুনরায় পরিষ্কার ছবি আপলোড করুন।';
                    }

                    await repo.updateNidStatus(
                      userId: widget.user.id,
                      nidStatus: VerificationStatus.rejected,
                      rejectionReason: reason,
                    );

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${widget.user.name} এর এনআইডি বাতিল করা হয়েছে। ইউজারকে পুনরায় আপলোডের নোটিশ পাঠানো হলো ❌'),
                          backgroundColor: const Color(0xFFDC2626),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.highlight_off_rounded, size: 18),
                  label: const Text('এনআইডি বাতিল ও পুনরায় ছবি চান (Reject ❌)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 5. OTHER DOCUMENTS SECTION (Trade License / Krishi Card)
  Widget _buildOtherDocumentsSection(bool isBuyer) {
    if (isBuyer && widget.user.tradeLicenseUrl != null && widget.user.tradeLicenseUrl!.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ব্যবসায়িক নথি ও ট্রেড লাইসেন্স (Trade License Document)',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 8),
          _buildModernDocCard(
            title: 'ট্রেড লাইসেন্স কপি (Trade License)',
            subtitle: 'ব্যবসায়িক সনদপত্র',
            imgUrl: widget.user.tradeLicenseUrl!,
            icon: Icons.receipt_long_rounded,
          ),
        ],
      );
    }

    if (!isBuyer && widget.user.krishiCardDocUrl != null && widget.user.krishiCardDocUrl!.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'কৃষি নথি ও কার্ড (Krishi Card Document)',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 8),
          _buildModernDocCard(
            title: 'কৃষি কার্ড / খামার নথি (Krishi Document)',
            subtitle: 'কৃষি সম্প্রসারণ অধিদপ্তর কর্তৃক প্রদত্ত কার্ড বা পরচা',
            imgUrl: widget.user.krishiCardDocUrl!,
            icon: Icons.file_present_rounded,
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildModernDocCard({
    required String title,
    required String subtitle,
    required String imgUrl,
    required IconData icon,
  }) {
    final bool hasImage = imgUrl.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Doc Card Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: const Color(0xFF0284C7)),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (hasImage)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.zoom_in_rounded, size: 12, color: Color(0xFF0369A1)),
                        SizedBox(width: 2),
                        Text(
                          'জুম',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0369A1)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Doc Thumbnail / Image
          InkWell(
            onTap: hasImage ? () => _openImagePreview(context, title, imgUrl) : null,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(14),
              bottomRight: Radius.circular(14),
            ),
            child: Container(
              height: 140,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
              ),
              child: hasImage
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(14),
                            bottomRight: Radius.circular(14),
                          ),
                          child: Image.network(
                            imgUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (ctx, child, progress) {
                              if (progress == null) return child;
                              return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                            },
                            errorBuilder: (ctx, err, stack) => _buildEmptyDocPlaceholder('ছবি লোড করা যায়নি'),
                          ),
                        ),
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.fullscreen_rounded, color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    )
                  : _buildEmptyDocPlaceholder('নথি সংযুক্ত করা হয়নি'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDocPlaceholder(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insert_drive_file_outlined, size: 36, color: Colors.grey.shade400),
          const SizedBox(height: 6),
          Text(
            message,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // 6. INTERACTIVE ACCOUNT STATUS DECISION BAR & NOTE CONFIRMATION FLOW
  Widget _buildAccountActionButtons(AdminRepository repo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.rule_folder_rounded, size: 20, color: Color(0xFF0F172A)),
            const SizedBox(width: 8),
            const Text(
              'সামগ্রিক অ্যাকাউন্ট স্ট্যাটাস ও অনুমোদন অ্যাকশন:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const Spacer(),
            if (_selectedStatusToUpdate != null)
              TextButton.icon(
                onPressed: () {
                  setState(() => _selectedStatusToUpdate = null);
                },
                icon: const Icon(Icons.close, size: 16, color: Color(0xFF64748B)),
                label: const Text('বাতিল করুন', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'যে কোনো একটি স্ট্যাটাস বাটনে ক্লিক করলে মন্তব্য/নোট লেখার অপশন আসবে এবং নোটসহ চূড়ান্ত আপডেট কনফার্ম করতে পারবেন:',
          style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 12),

        // 5 Status Selection Buttons
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            // 1. Approve / Verified
            _buildStatusSelectButton(
              status: VerificationStatus.verified,
              label: 'অনুমোদন (Approve ✅)',
              icon: Icons.check_circle_rounded,
              bgColor: const Color(0xFF15803D),
              textColor: Colors.white,
            ),

            // 2. In Progress
            _buildStatusSelectButton(
              status: VerificationStatus.inProgress,
              label: 'প্রক্রিয়াধীন (In Progress 🔄)',
              icon: Icons.autorenew_rounded,
              bgColor: const Color(0xFF0284C7),
              textColor: Colors.white,
            ),

            // 3. Pending
            _buildStatusSelectButton(
              status: VerificationStatus.pending,
              label: 'অপেক্ষমাণ (Pending ⏳)',
              icon: Icons.hourglass_top_rounded,
              bgColor: const Color(0xFFD97706),
              textColor: Colors.white,
            ),

            // 4. Suspend
            _buildStatusSelectButton(
              status: VerificationStatus.suspended,
              label: 'স্থগিত (Suspend 🚫)',
              icon: Icons.block_rounded,
              bgColor: const Color(0xFFEA580C),
              textColor: Colors.white,
            ),

            // 5. Reject
            _buildStatusSelectButton(
              status: VerificationStatus.rejected,
              label: 'বাতিল (Reject ❌)',
              icon: Icons.cancel_rounded,
              bgColor: const Color(0xFFDC2626),
              textColor: Colors.white,
            ),
          ],
        ),

        // Dynamic Note and Confirmation Panel (Appears on status button click!)
        if (_selectedStatusToUpdate != null) ...[
          const SizedBox(height: 16),
          _buildNoteAndConfirmPanel(repo),
        ],
      ],
    );
  }

  Widget _buildStatusSelectButton({
    required VerificationStatus status,
    required String label,
    required IconData icon,
    required Color bgColor,
    required Color textColor,
  }) {
    final isSelected = _selectedStatusToUpdate == status;

    return InkWell(
      onTap: () => _selectStatusForUpdate(status),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: isSelected ? bgColor : bgColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.black87 : bgColor,
            width: isSelected ? 2.5 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: bgColor.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.check_circle : icon,
              size: 17,
              color: isSelected ? textColor : bgColor,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? textColor : bgColor,
                fontWeight: FontWeight.bold,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteAndConfirmPanel(AdminRepository repo) {
    final status = _selectedStatusToUpdate!;
    final quickNotes = _getQuickNotesForStatus(status);

    Color themeColor;
    String statusTitle;
    IconData statusIcon;

    switch (status) {
      case VerificationStatus.verified:
        themeColor = const Color(0xFF15803D);
        statusTitle = 'সম্পূর্ণ অ্যাকাউন্ট অনুমোদন (Verified ✅)';
        statusIcon = Icons.check_circle_rounded;
        break;
      case VerificationStatus.inProgress:
        themeColor = const Color(0xFF0284C7);
        statusTitle = 'প্রক্রিয়াধীন রাখা (In Progress 🔄)';
        statusIcon = Icons.autorenew_rounded;
        break;
      case VerificationStatus.pending:
        themeColor = const Color(0xFFD97706);
        statusTitle = 'অপেক্ষমাণ রাখা (Pending ⏳)';
        statusIcon = Icons.hourglass_top_rounded;
        break;
      case VerificationStatus.suspended:
        themeColor = const Color(0xFFEA580C);
        statusTitle = 'অ্যাকাউন্ট সাময়িক স্থগিত (Suspend 🚫)';
        statusIcon = Icons.block_rounded;
        break;
      case VerificationStatus.rejected:
        themeColor = const Color(0xFFDC2626);
        statusTitle = 'আবেদন বাতিল / প্রত্যাখ্যান (Reject ❌)';
        statusIcon = Icons.cancel_rounded;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: themeColor.withValues(alpha: 0.45), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header showing selected status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(statusIcon, size: 18, color: themeColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'নির্বাচিত সিদ্ধান্ত: $statusTitle',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: themeColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'এই সিদ্ধান্তের সাথে ব্যবহারকারীকে যে নোট বা মন্তব্য পাঠাতে চান তা নির্বাচন বা টাইপ করুন (ব্যবহারকারী অ্যাপের নোটিফিকেশনে দেখতে পাবেন):',
                      style: TextStyle(fontSize: 11.5, color: Color(0xFF475569)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Quick Suggestion Chips for this selected status
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: quickNotes.map((note) {
              return InkWell(
                onTap: () {
                  setState(() {
                    _noteController.text = note;
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: themeColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_circle_outline_rounded, size: 13, color: themeColor),
                      const SizedBox(width: 4),
                      Text(
                        note,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF334155),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),

          // Note Input Box
          TextField(
            controller: _noteController,
            maxLines: 2,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'ব্যবহারকারীর জন্য সুনির্দিষ্ট মন্তব্য বা কারণ লিখুন...',
              hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: themeColor.withValues(alpha: 0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: themeColor, width: 1.8),
              ),
              contentPadding: const EdgeInsets.all(12),
              suffixIcon: _noteController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16, color: Colors.grey),
                      onPressed: () => setState(() => _noteController.clear()),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 14),

          // Confirmation Action Buttons (Submit Note & Status Together!)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: _isUpdatingStatus
                    ? null
                    : () {
                        setState(() => _selectedStatusToUpdate = null);
                      },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF64748B),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('বাতিল করুন'),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: _isUpdatingStatus
                    ? null
                    : () async {
                        setState(() => _isUpdatingStatus = true);
                        try {
                          final finalNote = _noteController.text.trim();
                          await repo.updateUserStatus(
                            userId: widget.user.id,
                            status: _selectedStatusToUpdate!,
                            adminNote: finalNote,
                          );

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${widget.user.name} এর স্ট্যাটাস সফলভাবে আপডেট ও ব্যবহারকারীকে নোটিফিকেশন পাঠানো হয়েছে ✅',
                                ),
                                backgroundColor: themeColor,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            setState(() {
                              _selectedStatusToUpdate = null;
                            });
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('আপডেট করতে সমস্যা হয়েছে: $e'),
                                backgroundColor: const Color(0xFFDC2626),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        } finally {
                          if (mounted) {
                            setState(() => _isUpdatingStatus = false);
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: _isUpdatingStatus
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.send_rounded, size: 17),
                label: Text(
                  _isUpdatingStatus
                      ? 'আপডেট হচ্ছে...'
                      : 'নোট ও স্ট্যাটাস কনফার্ম করুন (Confirm & Update 🚀)',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}
