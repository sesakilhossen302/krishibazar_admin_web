import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../../../Core/Network/admin_api_service.dart';
import '../../../../Utils/AppColors/app_colors.dart';
import '../../../../global/Model/admin_models.dart';
import '../../../../global/controller/admin_repository.dart';

class ProductDetailAdminModal extends StatefulWidget {
  final AdminProductApprovalRecord product;

  const ProductDetailAdminModal({super.key, required this.product});

  @override
  State<ProductDetailAdminModal> createState() => _ProductDetailAdminModalState();
}

class _ProductDetailAdminModalState extends State<ProductDetailAdminModal> {
  int _selectedImageIndex = 0;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isVideoError = false;
  bool _isPlaying = false;
  bool _isMuted = false;
  bool _isProcessingAction = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  void _initVideo() {
    final videoUrl = widget.product.videoUrl;
    if (videoUrl == null || videoUrl.trim().isEmpty) return;

    try {
      final uri = Uri.parse(videoUrl.trim());
      _videoController = VideoPlayerController.networkUrl(uri)
        ..initialize().then((_) {
          if (mounted) {
            setState(() {
              _isVideoInitialized = true;
            });
          }
        }).catchError((err) {
          debugPrint('⚠️ [ADMIN VIDEO ERROR]: $err');
          if (mounted) {
            setState(() {
              _isVideoError = true;
            });
          }
        });

      _videoController!.addListener(() {
        if (mounted) {
          final isPlaying = _videoController!.value.isPlaying;
          if (isPlaying != _isPlaying) {
            setState(() {
              _isPlaying = isPlaying;
            });
          }
        }
      });
    } catch (e) {
      debugPrint('⚠️ [ADMIN VIDEO INIT ERROR]: $e');
      _isVideoError = true;
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_videoController == null || !_isVideoInitialized) return;
    setState(() {
      if (_videoController!.value.isPlaying) {
        _videoController!.pause();
      } else {
        _videoController!.play();
      }
    });
  }

  void _toggleMute() {
    if (_videoController == null || !_isVideoInitialized) return;
    setState(() {
      _isMuted = !_isMuted;
      _videoController!.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _toBnDigits(dynamic input) {
    const bnDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    final str = input.toString();
    final sb = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      final char = str[i];
      final digit = int.tryParse(char);
      if (digit != null) {
        sb.write(bnDigits[digit]);
      } else {
        sb.write(char);
      }
    }
    return sb.toString();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AdminRepository>();
    final product = widget.product;
    final isApproved = product.isApproved;
    final images = product.imageUrls;
    final hasVideo = product.videoUrl != null && product.videoUrl!.trim().isNotEmpty;

    return Stack(
      children: [
        // Backdrop Scrim
        Positioned.fill(
          child: GestureDetector(
            onTap: repo.closeProductDetail,
            child: Container(
              color: Colors.black.withValues(alpha: 0.55),
            ),
          ),
        ),

        // Centered Modal Dialog
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820, maxHeight: 860),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Scaffold(
                backgroundColor: const Color(0xFFF8FAF8),
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  elevation: 0.5,
                  title: Row(
                    children: [
                      Text(product.emoji, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          product.title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isApproved ? const Color(0xFFDCFCE7) : const Color(0xFFFFEDD5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isApproved ? 'সক্রিয় (Active)' : 'পর্যালোচনায় (Pending)',
                          style: TextStyle(
                            color: isApproved ? const Color(0xFF166534) : const Color(0xFFEA580C),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black87),
                      tooltip: 'বন্ধ করুন',
                      onPressed: repo.closeProductDetail,
                    ),
                  ],
                ),
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Photo Gallery Section
                      if (images.isNotEmpty) ...[
                        _buildImageGallery(images),
                        const SizedBox(height: 20),
                      ],

                      // Field Video Player Section
                      if (hasVideo) ...[
                        _buildVideoSection(product),
                        const SizedBox(height: 20),
                      ],

                      // Price & Quantity Highlights Card
                      _buildPriceAndQuantityCard(product),
                      const SizedBox(height: 20),

                      // Farmer & Farm Details Card
                      _buildFarmerCard(product, repo),
                      const SizedBox(height: 20),

                      // Crop Description
                      if (product.description.isNotEmpty) ...[
                        _buildDescriptionCard(product),
                        const SizedBox(height: 20),
                      ],
                    ],
                  ),
                ),
                bottomNavigationBar: _buildActionBottomBar(context, repo, product),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageGallery(List<String> images) {
    final currentImage = images[_selectedImageIndex.clamp(0, images.length - 1)];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ফসলের ফটো গ্যালারি',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),
        // Main Active Image
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 280,
            width: double.infinity,
            color: const Color(0xFFE2E8F0),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    currentImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFDCFCE7),
                      child: Center(
                        child: Text(
                          widget.product.emoji,
                          style: const TextStyle(fontSize: 64),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_selectedImageIndex + 1} / ${images.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Thumbnails Strip (if multiple)
        if (images.length > 1) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final isSelected = idx == _selectedImageIndex;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedImageIndex = idx;
                    });
                  },
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF166534) : const Color(0xFFCBD5E1),
                        width: isSelected ? 2.5 : 1,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      images[idx],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image, size: 20),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVideoSection(AdminProductApprovalRecord product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.videocam_rounded, color: Color(0xFFEA580C), size: 20),
              const SizedBox(width: 8),
              const Text(
                'ক্ষেতের সরাসরি ভিডিও যাচাই',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const Spacer(),
              if (product.videoNote != null && product.videoNote!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    product.videoNote!,
                    style: const TextStyle(fontSize: 11, color: Color(0xFFEA580C), fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Player Area
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 240,
              width: double.infinity,
              color: Colors.black,
              child: _buildVideoContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoContent() {
    if (_isVideoError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.white60, size: 36),
            const SizedBox(height: 8),
            const Text(
              'ভিডিও লোড করা যায়নি',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _isVideoError = false;
                  _isVideoInitialized = false;
                });
                _initVideo();
              },
              child: const Text('পুনরায় চেষ্টা করুন', style: TextStyle(color: Color(0xFF4ADE80))),
            ),
          ],
        ),
      );
    }

    if (!_isVideoInitialized || _videoController == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white70),
            SizedBox(height: 12),
            Text('ভিডিও প্রস্তুত হচ্ছে...', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: _togglePlayPause,
          child: Center(
            child: AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            ),
          ),
        ),

        // Play / Pause Overlay Icon
        if (!_isPlaying)
          GestureDetector(
            onTap: _togglePlayPause,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36),
            ),
          ),

        // Bottom Controls Bar
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.85)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: _togglePlayPause,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: VideoProgressIndicator(
                      _videoController!,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: Color(0xFF166534),
                        bufferedColor: Colors.white24,
                        backgroundColor: Colors.white12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ValueListenableBuilder<VideoPlayerValue>(
                  valueListenable: _videoController!,
                  builder: (context, value, child) {
                    return Text(
                      '${_formatDuration(value.position)} / ${_formatDuration(value.duration)}',
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    );
                  },
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(
                    _isMuted ? Icons.volume_off : Icons.volume_up,
                    color: Colors.white,
                    size: 18,
                  ),
                  onPressed: _toggleMute,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceAndQuantityCard(AdminProductApprovalRecord product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'মূল্য ও পরিমাণের বিস্তারিত',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoTile(
                  label: 'মোট পরিমাণ',
                  value: '${_toBnDigits(product.quantity.toInt())} ${product.unitLabel}',
                  icon: Icons.inventory_2_outlined,
                  iconColor: const Color(0xFF166534),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoTile(
                  label: 'অবশিষ্ট স্টক',
                  value: '${_toBnDigits(product.remainingQuantity.toInt())} ${product.unitLabel}',
                  icon: Icons.pie_chart_outline,
                  iconColor: const Color(0xFF0284C7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoTile(
                  label: 'প্রত্যাশিত মূল্য',
                  value: '৳${_toBnDigits(product.pricePerUnit.toInt())} / ${product.unitLabel}',
                  icon: Icons.sell_outlined,
                  iconColor: const Color(0xFFEA580C),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoTile(
                  label: 'গুণগত মান (Grade)',
                  value: product.qualityGrade,
                  icon: Icons.verified_outlined,
                  iconColor: const Color(0xFFEAB308),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoTile(
                  label: 'ফসল তোলার তারিখ',
                  value: product.harvestDate.isNotEmpty ? product.harvestDate : 'উল্লেখ নেই',
                  icon: Icons.calendar_today_outlined,
                  iconColor: const Color(0xFF475569),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoTile(
                  label: 'ক্যাটাগরি',
                  value: product.category,
                  icon: Icons.category_outlined,
                  iconColor: const Color(0xFF166534),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmerCard(AdminProductApprovalRecord product, AdminRepository repo) {
    final matchingFarmer = repo.farmers.cast<FarmerVerificationRecord?>().firstWhere(
      (f) => f != null && (
        (product.farmerId.isNotEmpty && f.id == product.farmerId) ||
        f.name.trim().toLowerCase() == product.farmerName.trim().toLowerCase() ||
        (product.farmerPhone.isNotEmpty && f.phone.replaceAll(RegExp(r'\D'), '') == product.farmerPhone.replaceAll(RegExp(r'\D'), ''))
      ),
      orElse: () => null,
    );

    String resolvedPhoto = product.farmerPhotoUrl.isNotEmpty
        ? product.farmerPhotoUrl
        : (matchingFarmer?.photoUrl ?? '');
    if (resolvedPhoto.isNotEmpty) {
      resolvedPhoto = AdminApiService.formatMediaUrl(resolvedPhoto);
    }

    final farmerProducts = repo.products.where((p) =>
      p.farmerId == product.farmerId ||
      p.farmerName.trim().toLowerCase() == product.farmerName.trim().toLowerCase() ||
      (product.farmerPhone.isNotEmpty && p.farmerPhone.replaceAll(RegExp(r'\D'), '') == product.farmerPhone.replaceAll(RegExp(r'\D'), ''))
    ).toList();
    final int totalProductsCount = farmerProducts.isNotEmpty
        ? farmerProducts.length
        : (matchingFarmer?.productsCount ?? 1);

    final isFarmerVerified = product.farmerVerified || (matchingFarmer?.status == VerificationStatus.verified);

    return Container(
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
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'কৃষক ও খামারের তথ্য',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'মোট ${_toBnDigits(totalProductsCount)} টি পণ্য লিস্টিং',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF166534),
                      ),
                    ),
                  ),
                ],
              ),
              // View Full Profile Action Button
              ElevatedButton.icon(
                onPressed: () => repo.openFarmerDetailFromProduct(product),
                icon: const Icon(Icons.person_search_rounded, size: 15, color: Colors.white),
                label: const Text(
                  'ইউজার প্রোফাইল ও তথ্য দেখুন →',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF166534),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Clickable Farmer Row
          InkWell(
            onTap: () => repo.openFarmerDetailFromProduct(product),
            borderRadius: BorderRadius.circular(12),
            hoverColor: const Color(0xFFF0FDF4),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  // Real Photo or Fallback Avatar
                  Tooltip(
                    message: 'কৃষকের প্রোফাইল ও বিস্তারিত দেখতে ক্লিক করুন',
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isFarmerVerified ? const Color(0xFF16A34A) : const Color(0xFFCBD5E1),
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: resolvedPhoto.isNotEmpty
                            ? Image.network(
                                resolvedPhoto,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                loadingBuilder: (ctx, child, progress) {
                                  if (progress == null) return child;
                                  return const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF166534)),
                                    ),
                                  );
                                },
                                errorBuilder: (ctx, err, stack) => _buildFarmerAvatarFallback(product.farmerName),
                              )
                            : _buildFarmerAvatarFallback(product.farmerName),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Name, Verification, Location & Stats
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                product.farmerName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isFarmerVerified) ...[
                              const SizedBox(width: 6),
                              const Icon(Icons.verified, color: Color(0xFF166534), size: 18),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'ভেরিফাইড কৃষক',
                                  style: TextStyle(
                                    color: Color(0xFF166534),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF64748B)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                product.location,
                                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '🌾 মোট ${_toBnDigits(totalProductsCount)} টি পণ্য লিস্টিং করেছেন • সম্পূর্ণ প্রোফাইল ও সব তথ্য দেখতে ক্লিক করুন',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF166534),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Phone Badge & Arrow
                  if (product.farmerPhone.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.phone, size: 14, color: Color(0xFF166534)),
                          const SizedBox(width: 6),
                          Text(
                            product.farmerPhone,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],

                  // Arrow forward circle
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF0FDF4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Color(0xFF166534),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmerAvatarFallback(String name) {
    final initial = name.trim().isNotEmpty ? name.trim().characters.first.toUpperCase() : 'ক';
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF166534), Color(0xFF22C55E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionCard(AdminProductApprovalRecord product) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ফসলের বিবরণ ও বৈশিষ্ট্য',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            product.description,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF334155),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBottomBar(
    BuildContext context,
    AdminRepository repo,
    AdminProductApprovalRecord product,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Delete button
          OutlinedButton.icon(
            onPressed: _isProcessingAction
                ? null
                : () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('লিস্টিং মুছে ফেলবেন?'),
                        content: Text("'${product.title}' লিস্টিংটি স্থায়ীভাবে মুছে ফেলা হবে।"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('বাতিল'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('মুছে ফেলুন', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      setState(() => _isProcessingAction = true);
                      await repo.deleteProductListing(product.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('পণ্যটি সফলভাবে মুছে ফেলা হয়েছে'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
            label: const Text('লিস্টিং মুছুন', style: TextStyle(color: Colors.red)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFFECACA)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),

          Row(
            children: [
              // Reject button (if active)
              if (product.isApproved)
                ElevatedButton.icon(
                  onPressed: _isProcessingAction
                      ? null
                      : () async {
                          setState(() => _isProcessingAction = true);
                          await repo.rejectProduct(product.id);
                          setState(() => _isProcessingAction = false);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('পণ্যটি বাতিল করা হয়েছে'),
                                backgroundColor: Color(0xFFEA580C),
                              ),
                            );
                          }
                        },
                  icon: const Icon(Icons.block, size: 18),
                  label: const Text('বাতিল করুন'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEA580C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),

              // Approve button (if pending or rejected)
              if (!product.isApproved) ...[
                ElevatedButton.icon(
                  onPressed: _isProcessingAction
                      ? null
                      : () async {
                          setState(() => _isProcessingAction = true);
                          await repo.approveProduct(product.id);
                          setState(() => _isProcessingAction = false);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('✓ পণ্যটি সফলভাবে অনুমোদন ও সক্রিয় করা হয়েছে!'),
                                backgroundColor: Color(0xFF166534),
                              ),
                            );
                          }
                        },
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('অনুমোদন করুন (Approve)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF166534),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
