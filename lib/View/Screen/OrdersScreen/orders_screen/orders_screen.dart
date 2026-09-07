import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Utils/AppColors/app_colors.dart';
import '../../../../global/Model/admin_models.dart';
import '../../../../global/controller/admin_repository.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AdminRepository>();
    final orders = repo.orders;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'সকল অর্ডার ট্র্যাকিং (${orders.length} টি)',
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
              final list = orders.map((order) {
                Color badgeBg;
                Color badgeText;
                switch (order.orderStatus) {
                  case OrderStatus.completed:
                    badgeBg = const Color(0xFFDCFCE7);
                    badgeText = const Color(0xFF166534);
                    break;
                  case OrderStatus.inTransit:
                    badgeBg = const Color(0xFFE0F2FE);
                    badgeText = const Color(0xFF0369A1);
                    break;
                  case OrderStatus.collected:
                    badgeBg = const Color(0xFFCCFBF1);
                    badgeText = const Color(0xFF0F766E);
                    break;
                  case OrderStatus.preparing:
                    badgeBg = const Color(0xFFFEF9C3);
                    badgeText = const Color(0xFFA16207);
                    break;
                  default:
                    badgeBg = const Color(0xFFF1F5F9);
                    badgeText = Colors.black;
                }

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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            order.orderNumber,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF166534),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              order.orderStatus.labelBn,
                              style: TextStyle(
                                color: badgeText,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        order.productTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${order.farmerName} ➔ ${order.buyerName}',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'মোট মূল্য: ৳${order.totalAmount.toInt()} • ${order.transportStatusText}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEA580C),
                        ),
                      ),
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
