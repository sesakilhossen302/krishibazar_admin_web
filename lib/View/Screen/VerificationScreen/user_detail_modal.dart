import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
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

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.user.adminNotes);
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
    final repo = context.read<AdminRepository>();
    final isBuyer = widget.user.role == UserRole.buyer;

    return Container(
      color: Colors.black.withValues(alpha: 0.65),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 720,
              maxHeight: MediaQuery.of(context).size.height * 0.92,
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
                          // Contact & Identity Grid (Phone, Email, NID, Status)
                          _buildContactAndIdentityGrid(isBuyer),

                          const SizedBox(height: 16),

                          // Location / Address Section (Card style with multiline wrap)
                          _buildLocationSection(),

                          const SizedBox(height: 16),

                          // Farm or Business Specifics Section
                          if (isBuyer)
                            _buildBuyerDetailsSection()
                          else
                            _buildFarmerDetailsSection(),

                          const SizedBox(height: 24),

                          // Document Inspection Section
                          _buildDocumentsSection(isBuyer),

                          const SizedBox(height: 24),

                          // Admin Notes & Reason Input
                          _buildAdminNoteField(),

                          const SizedBox(height: 24),

                          // Verification Decision & Actions Bar
                          _buildActionButtons(repo),

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
                          widget.user.photoUrl!,
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
                label: 'বর্তমান অবস্থা',
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
                    label: 'বর্তমান অবস্থা',
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

  // 2. LOCATION & ADDRESS SECTION (WRAPS PROPERLY, ZERO OVERFLOW)
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
                const Row(
                  children: [
                    Text(
                      'এলাকা ও সম্পূর্ণ ঠিকানা',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF166534),
                      ),
                    ),
                  ],
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

  // 5. DOCUMENTS SECTION
  Widget _buildDocumentsSection(bool isBuyer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.folder_shared_rounded, size: 20, color: Color(0xFF0F172A)),
                SizedBox(width: 8),
                Text(
                  'সংযুক্ত নথিপত্র ও ছবি (Uploaded Documents)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'ক্লিক করে বড় দেখুন',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Document Cards
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
            const SizedBox(width: 14),
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
        if (isBuyer && widget.user.tradeLicenseUrl != null && widget.user.tradeLicenseUrl!.isNotEmpty) ...[
          const SizedBox(height: 14),
          _buildModernDocCard(
            title: 'ট্রেড লাইসেন্স কপি (Trade License)',
            subtitle: 'ব্যবসায়িক সনদপত্র',
            imgUrl: widget.user.tradeLicenseUrl!,
            icon: Icons.receipt_long_rounded,
          ),
        ],
        if (!isBuyer && widget.user.krishiCardDocUrl != null && widget.user.krishiCardDocUrl!.isNotEmpty) ...[
          const SizedBox(height: 14),
          _buildModernDocCard(
            title: 'কৃষি কার্ড / জমির পরচা (Farmer Document)',
            subtitle: 'সরকারি কৃষি কার্ড বা খামার সংক্রান্ত নথি',
            imgUrl: widget.user.krishiCardDocUrl!,
            icon: Icons.file_present_rounded,
          ),
        ],
      ],
    );
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

  // 6. ADMIN NOTE INPUT FIELD
  Widget _buildAdminNoteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.edit_note_rounded, size: 20, color: Color(0xFF0F172A)),
            SizedBox(width: 8),
            Text(
              'অ্যাডমিন নোট / মন্তব্যের বিবরণ (Admin Review Notes)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _noteController,
          maxLines: 2,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: 'যাচাই অনুমোদন, প্রত্যাখ্যান বা পর্যালোচনার কারণ লিখুন...',
            hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF16A34A), width: 1.5),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  // 7. ACTION BUTTONS (APPROVE, IN REVIEW, PENDING, SUSPEND, REJECT)
  Widget _buildActionButtons(AdminRepository repo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'স্ট্যাটাস পরিবর্তন ও অনুমোদন সংক্রান্ত অ্যাকশন:',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            // Approve / Verified (Primary Emerald Green)
            ElevatedButton.icon(
              onPressed: () async {
                await repo.updateUserStatus(
                  userId: widget.user.id,
                  status: VerificationStatus.verified,
                  adminNote: _noteController.text,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${widget.user.name} এর প্রোফাইল সফলভাবে যাচাই ও অনুমোদন করা হয়েছে ✅'),
                      backgroundColor: const Color(0xFF15803D),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.check_circle_rounded, size: 18),
              label: const Text('অনুমোদন করুন (Approve ✅)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF15803D),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),

            // In Progress (Blue)
            ElevatedButton.icon(
              onPressed: () async {
                await repo.updateUserStatus(
                  userId: widget.user.id,
                  status: VerificationStatus.inProgress,
                  adminNote: _noteController.text,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${widget.user.name} এর প্রোফাইল পর্যালোচনাধীন রাখা হলো 🔄'),
                      backgroundColor: const Color(0xFF0284C7),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.autorenew_rounded, size: 18),
              label: const Text('প্রক্রিয়াধীন (In Progress 🔄)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),

            // Pending (Amber)
            ElevatedButton.icon(
              onPressed: () async {
                await repo.updateUserStatus(
                  userId: widget.user.id,
                  status: VerificationStatus.pending,
                  adminNote: _noteController.text,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${widget.user.name} এর প্রোফাইল অপেক্ষমাণ রাখা হলো ⏳'),
                      backgroundColor: const Color(0xFFD97706),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.hourglass_top_rounded, size: 18),
              label: const Text('অপেক্ষমাণ (Pending ⏳)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD97706),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),

            // Suspend (Outlined Orange)
            OutlinedButton.icon(
              onPressed: () {
                repo.suspendUser(
                  userId: widget.user.id,
                  adminNote: _noteController.text,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${widget.user.name} এর অ্যাকাউন্ট সাময়িক স্থগিত করা হলো 🚫'),
                    backgroundColor: const Color(0xFFEA580C),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.block_rounded, size: 16, color: Color(0xFFEA580C)),
              label: const Text('স্থগিত (Suspend 🚫)', style: TextStyle(color: Color(0xFFEA580C))),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFEA580C)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),

            // Reject / Delete (Outlined Red)
            OutlinedButton.icon(
              onPressed: () {
                repo.deleteUser(
                  userId: widget.user.id,
                  adminNote: _noteController.text,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${widget.user.name} এর আবেদন বাতিল ও মুছে ফেলা হয়েছে ❌'),
                    backgroundColor: const Color(0xFFDC2626),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.cancel_rounded, size: 16, color: Color(0xFFDC2626)),
              label: const Text('বাতিল / মুছুন (Reject ❌)', style: TextStyle(color: Color(0xFFDC2626))),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFDC2626)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
