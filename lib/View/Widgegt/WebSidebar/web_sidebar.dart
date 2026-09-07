import 'package:flutter/material.dart';
import '../../../Utils/AppColors/app_colors.dart';

class WebSidebarItem {
  final IconData icon;
  final String title;

  WebSidebarItem({required this.icon, required this.title});
}

class WebSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const WebSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      WebSidebarItem(icon: Icons.dashboard_outlined, title: 'ওভারভিউ'),
      WebSidebarItem(icon: Icons.agriculture_outlined, title: 'কৃষক যাচাই'),
      WebSidebarItem(icon: Icons.storefront_outlined, title: 'ক্রেতা যাচাই'),
      WebSidebarItem(icon: Icons.inventory_2_outlined, title: 'পণ্য অনুমোদন'),
      WebSidebarItem(icon: Icons.campaign_outlined, title: 'চাহিদা তদারকি'),
      WebSidebarItem(icon: Icons.local_shipping_outlined, title: 'অর্ডার ট্র্যাকিং'),
      WebSidebarItem(icon: Icons.gavel_outlined, title: 'অভিযোগ নিষ্পত্তি'),
    ];

    return Container(
      width: 260,
      color: AppColors.sidebarBg,
      child: Column(
        children: [
          // Logo & Branding
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.black.withValues(alpha: 0.2),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('🌾', style: TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'কৃষি বাজার',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'অ্যাডমিন ড্যাশবোর্ড',
                        style: TextStyle(color: AppColors.primaryGold, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = selectedIndex == index;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: InkWell(
                    onTap: () => onItemSelected(index),
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryGreen : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item.icon,
                            color: isSelected ? Colors.white : AppColors.textMuted,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.title,
                              style: TextStyle(
                                color: isSelected ? Colors.white : AppColors.textMuted,
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Footer / System Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primaryGold,
                  child: Icon(Icons.shield, size: 18, color: Colors.black),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('অ্যাডমিন পোর্টাল v2.4', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      Text('সুরক্ষিত সার্ভার সংযোগ', style: TextStyle(color: Colors.grey, fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
