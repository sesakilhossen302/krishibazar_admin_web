import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Utils/AppColors/app_colors.dart';
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
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 900,
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 20)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Full Screen Image Dialog Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFF14532D),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.zoom_in_rounded, color: Colors.white, size: 22),
                        const SizedBox(width: 8),
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
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              ),

              // Interactive Image Viewer (Pan & Zoomable)
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  child: Container(
                    color: const Color(0xFF0F172A),
                    child: InteractiveViewer(
                      panEnabled: true,
                      boundaryMargin: const EdgeInsets.all(20),
                      minScale: 0.8,
                      maxScale: 4.0,
                      child: Center(
                        child: Image.network(
                          imgUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (c, e, s) => const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.broken_image_rounded, color: Colors.white54, size: 64),
                                SizedBox(height: 12),
                                Text(
                                  'ছবি লোড করা যায়নি',
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

  @override
  Widget build(BuildContext context) {
    final repo = context.read<AdminRepository>();
    final isBuyer = widget.user.role == UserRole.buyer;

    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 680,
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modal Title Bar
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: isBuyer ? AppColors.primaryGold : AppColors.primaryGreen,
                      child: Icon(
                        isBuyer ? Icons.storefront_rounded : Icons.agriculture_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.user.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            isBuyer ? 'পাইকারি ক্রেতা / দোকানদার' : 'কৃষক / উৎপাদনকারী',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => repo.closeUserDetail(),
                    ),
                  ],
                ),
                const Divider(height: 24),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status & Basic Details Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              _buildInfoRow('ফোন নম্বর:', widget.user.phone),
                              _buildInfoRow('ইমেইল ঠিকানা:', widget.user.email),
                              _buildInfoRow('এনআইডি (NID) নম্বর:', widget.user.nid),
                              _buildInfoRow('এলাকা/ঠিকানা:', widget.user.location),
                              if (isBuyer) ...[
                                _buildInfoRow('দোকানের নাম:', widget.user.storeName ?? 'N/A'),
                                _buildInfoRow('ট্রেড লাইসেন্স:', widget.user.tradeLicenseNo ?? 'N/A'),
                                _buildInfoRow('বিজনেস লাইসেন্স:', widget.user.businessLicenseNo ?? 'N/A'),
                              ] else ...[
                                _buildInfoRow('চাষের ধরন:', widget.user.farmerType ?? 'N/A'),
                              ],
                              _buildInfoRow('বর্তমান স্ট্যাটাস:', widget.user.status.labelBn),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Document Inspection Section (NID & Trade License Images)
                        const Text(
                          'নথিপত্র ও ছবি ভেরিফিকেশন (Uploaded Documents)',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: _buildDocCard(
                                title: 'এনআইডি (সামনের দিক)',
                                imgUrl: widget.user.nidFrontUrl,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildDocCard(
                                title: 'এনআইডি (পেছনের দিক)',
                                imgUrl: widget.user.nidBackUrl,
                              ),
                            ),
                          ],
                        ),
                        if (isBuyer) ...[
                          const SizedBox(height: 12),
                          _buildDocCard(
                            title: 'ট্রেড লাইসেন্স (Trade License Document)',
                            imgUrl: widget.user.tradeLicenseUrl ?? widget.user.nidFrontUrl,
                          ),
                        ],
                        const SizedBox(height: 20),

                        // Admin Note Input Field
                        const Text(
                          'অ্যাডমিন মন্তব্য / নোট (Admin Reason & Notes)',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _noteController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            hintText: 'স্ট্যাটাস পরিবর্তন বা মুছতে চাইলে মন্তব্য লিখুন...',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.all(12),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Action Controls
                        const Text(
                          'স্ট্যাটাস পরিবর্তন ও অ্যাকশনসমূহ:',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => repo.updateUserStatus(
                                userId: widget.user.id,
                                status: VerificationStatus.verified,
                                adminNote: _noteController.text,
                              ),
                              icon: const Icon(Icons.check_circle_rounded, size: 16),
                              label: const Text('যাচাইকৃত (Verified ✅)'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF166534),
                                foregroundColor: Colors.white,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => repo.updateUserStatus(
                                userId: widget.user.id,
                                status: VerificationStatus.inProgress,
                                adminNote: _noteController.text,
                              ),
                              icon: const Icon(Icons.autorenew_rounded, size: 16),
                              label: const Text('প্রক্রিয়াধীন (In Progress 🔄)'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0284C7),
                                foregroundColor: Colors.white,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => repo.updateUserStatus(
                                userId: widget.user.id,
                                status: VerificationStatus.pending,
                                adminNote: _noteController.text,
                              ),
                              icon: const Icon(Icons.hourglass_empty_rounded, size: 16),
                              label: const Text('অপেক্ষমাণ (Pending ⏳)'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEA580C),
                                foregroundColor: Colors.white,
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => repo.suspendUser(
                                userId: widget.user.id,
                                adminNote: _noteController.text,
                              ),
                              icon: const Icon(Icons.block_rounded, size: 16, color: Colors.orange),
                              label: const Text('সাময়িক স্থগিত (Suspend 🚫)', style: TextStyle(color: Colors.orange)),
                              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.orange)),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => repo.deleteUser(
                                userId: widget.user.id,
                                adminNote: _noteController.text,
                              ),
                              icon: const Icon(Icons.delete_forever_rounded, size: 16, color: Colors.red),
                              label: const Text('অ্যাকাউন্ট মুছুন (Delete 🗑️)', style: TextStyle(color: Colors.red)),
                              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildDocCard({required String title, required String imgUrl}) {
    return InkWell(
      onTap: () => _openImagePreview(context, title, imgUrl),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                const Row(
                  children: [
                    Icon(Icons.zoom_in, size: 14, color: Color(0xFF0284C7)),
                    SizedBox(width: 2),
                    Text(
                      'বড় করে দেখুন',
                      style: TextStyle(fontSize: 10, color: Color(0xFF0284C7), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  Image.network(
                    imgUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(
                      height: 120,
                      color: Colors.grey.shade200,
                      child: const Center(child: Icon(Icons.insert_drive_file_outlined, size: 40, color: Colors.grey)),
                    ),
                  ),
                  Positioned(
                    right: 6,
                    bottom: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.fullscreen_rounded, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
