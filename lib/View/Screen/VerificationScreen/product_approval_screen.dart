import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Utils/AppColors/app_colors.dart';
import '../../../../global/controller/admin_repository.dart';

class ProductApprovalScreen extends StatelessWidget {
  const ProductApprovalScreen({super.key});

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
    final products = repo.products;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'পণ্য অনুমোদন (${_toBnDigits(products.length)} টি)',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Color(0xFF166534)),
                tooltip: 'রিফ্রেশ করুন',
                onPressed: repo.fetchProductsFromBackend,
              ),
            ],
          ),
          const SizedBox(height: 16),

          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 900;
              final list = products.map((prod) {
                final isApproved = prod.isApproved;
                final hasImages = prod.imageUrls.isNotEmpty;
                final hasVideo = prod.videoUrl != null && prod.videoUrl!.trim().isNotEmpty;

                return Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  elevation: 1,
                  shadowColor: Colors.black.withValues(alpha: 0.08),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => repo.openProductDetail(prod),
                    hoverColor: const Color(0xFFF1F8F3),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image or Emoji Preview
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  width: 52,
                                  height: 52,
                                  color: const Color(0xFFDCFCE7),
                                  child: hasImages
                                      ? Image.network(
                                          prod.imageUrls.first,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Center(
                                            child: Text(prod.emoji, style: const TextStyle(fontSize: 26)),
                                          ),
                                        )
                                      : Center(
                                          child: Text(prod.emoji, style: const TextStyle(fontSize: 26)),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Product Title & Metadata
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            prod.title,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (hasVideo) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFF7ED),
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: const Color(0xFFFDBA74)),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.play_circle_fill, size: 12, color: Color(0xFFEA580C)),
                                                SizedBox(width: 3),
                                                Text(
                                                  'ভিডিও',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFFEA580C),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'কৃষক: ${prod.farmerName} • 📍 ${prod.location}',
                                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_toBnDigits(prod.quantity.toInt())} ${prod.unitLabel} @ ৳${_toBnDigits(prod.pricePerUnit.toInt())} • মান: ${prod.qualityGrade}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF334155),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Status Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: isApproved ? const Color(0xFFDCFCE7) : const Color(0xFFFFEDD5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isApproved ? 'সক্রিয় (Active)' : 'পর্যালোচনায় (Pending)',
                                  style: TextStyle(
                                    color: isApproved ? const Color(0xFF166534) : const Color(0xFFEA580C),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const Spacer(),
                          const Divider(height: 16, color: Color(0xFFF1F5F9)),

                          // Action Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton.icon(
                                onPressed: () => repo.openProductDetail(prod),
                                icon: const Icon(Icons.visibility_outlined, size: 16, color: Color(0xFF166534)),
                                label: const Text(
                                  'বিস্তারিত দেখুন',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                                ),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),

                              if (!isApproved)
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    await repo.approveProduct(prod.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('✓ পণ্যটি অনুমোদন করা হয়েছে!'),
                                          backgroundColor: Color(0xFF166534),
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.check, size: 15),
                                  label: const Text('অনুমোদন করুন', style: TextStyle(fontSize: 12)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF166534),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList();

              if (isDesktop) {
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    mainAxisExtent: 165,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: list.length,
                  itemBuilder: (context, index) => list[index],
                );
              }

              return Column(
                children: list
                    .map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: SizedBox(height: 165, child: item),
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
