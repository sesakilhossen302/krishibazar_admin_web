import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Utils/AppColors/app_colors.dart';
import '../../../../global/Model/admin_models.dart';
import '../../../../global/controller/admin_repository.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AdminRepository>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'প্ল্যাটফর্ম সারসংক্ষেপ (Platform GMV & Metrics)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Responsive Grid for Metric Cards (4 cols on Desktop, 3 on Tablet, 2 on Mobile)
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final crossAxisCount = width >= 1100 ? 4 : (width >= 700 ? 3 : 2);
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  mainAxisExtent: 130,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 6,
                itemBuilder: (context, index) {
                  final metrics = [
                    _buildMetricCard(
                      title: 'মোট লেনদেন (GMV)',
                      value: '৳৭৭২৭০০০',
                      subtitle: '১০টি সক্রিয় চুক্তি',
                      icon: Icons.sync,
                      iconBg: const Color(0xFFDCFCE7),
                      iconColor: const Color(0xFF166534),
                      valueColor: const Color(0xFF166534),
                    ),
                    _buildMetricCard(
                      title: 'প্ল্যাটফর্ম আয় (২%)',
                      value: '৳১৫৪৪৬',
                      subtitle: 'অটোমেটেড এসক্রো ফি',
                      icon: Icons.attach_money_rounded,
                      iconBg: const Color(0xFFFFEDD5),
                      iconColor: const Color(0xFFEA580C),
                      valueColor: const Color(0xFFEA580C),
                    ),
                    _buildMetricCard(
                      title: 'নিবন্ধিত কৃষক',
                      value: '${repo.farmers.length} জন',
                      subtitle: '${repo.farmers.where((f) => f.status == VerificationStatus.verified).length} জন যাচাইকৃত',
                      icon: Icons.agriculture_rounded,
                      iconBg: const Color(0xFFDCFCE7),
                      iconColor: const Color(0xFF166534),
                      valueColor: const Color(0xFF166534),
                    ),
                    _buildMetricCard(
                      title: 'পাইকারি ক্রেতা',
                      value: '${repo.buyers.length} প্রতিষ্ঠান',
                      subtitle: '${repo.buyers.where((b) => b.status == VerificationStatus.verified).length} প্রতিষ্ঠান যাচাইকৃত',
                      icon: Icons.storefront_rounded,
                      iconBg: const Color(0xFFDCFCE7),
                      iconColor: const Color(0xFF166534),
                      valueColor: const Color(0xFF166534),
                    ),
                    _buildMetricCard(
                      title: 'পণ্য লিস্টিং',
                      value: '২০ টি',
                      subtitle: '১৮ টি সক্রিয়',
                      icon: Icons.inventory_2_rounded,
                      iconBg: const Color(0xFFDCFCE7),
                      iconColor: const Color(0xFF166534),
                      valueColor: const Color(0xFF166534),
                    ),
                    _buildMetricCard(
                      title: 'ক্রেতার চাহিদা',
                      value: '১০ টি',
                      subtitle: 'ঢাকা ও অন্যান্য আড়ত',
                      icon: Icons.campaign_rounded,
                      iconBg: const Color(0xFFDCFCE7),
                      iconColor: const Color(0xFF166534),
                      valueColor: const Color(0xFF166534),
                    ),
                  ];
                  return metrics[index];
                },
              );
            },
          ),
          const SizedBox(height: 24),

          // Dispute Summary Card matching Screenshot 1
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'অভিযোগ ও ডিসপুট সংক্রান্ত',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF15803D),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'মোট ১টি অভিযোগ (০টি খোলা)',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF15803D),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'নিষ্পত্তি হয়েছে',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: Icon(icon, size: 20, color: iconColor),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: valueColor),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
