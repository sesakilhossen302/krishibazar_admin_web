import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Utils/AppColors/app_colors.dart';
import '../../../../global/Model/admin_models.dart';
import '../../../../global/controller/admin_repository.dart';

class ProductApprovalScreen extends StatelessWidget {
  const ProductApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AdminRepository>();
    final products = repo.products;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'পণ্য অনুমোদন (${products.length} টি)',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 900;
              final list = products.map((prod) {
                final isApproved = prod.isApproved;
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(prod.emoji, style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  prod.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'কৃষক: ${prod.farmerName} • ${prod.location}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${prod.quantity.toInt()} ${prod.unit.labelBn} @ ৳${prod.pricePerUnit.toInt()} • মান: ${prod.qualityGrade}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                      if (!isApproved) ...[
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => repo.approveProduct(prod.id),
                              icon: const Icon(Icons.check, size: 16),
                              label: const Text('অনুমোদন করুন'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF166534),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              }).toList();

              if (isDesktop) {
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    mainAxisExtent: 175,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: list.length,
                  itemBuilder: (context, index) => list[index],
                );
              }

              return Column(
                children: list.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: item,
                )).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
