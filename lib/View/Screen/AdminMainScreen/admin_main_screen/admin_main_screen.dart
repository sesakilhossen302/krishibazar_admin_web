import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Utils/AppColors/app_colors.dart';
import '../../../../global/controller/admin_repository.dart';

import '../../../Widgegt/WebHeader/web_header.dart';
import '../../../Widgegt/WebSidebar/web_sidebar.dart';
import '../../DisputesScreen/disputes_screen/disputes_screen.dart';
import '../../OrdersScreen/orders_screen/orders_screen.dart';
import '../../OverviewScreen/overview_screen/overview_screen.dart';
import '../../VerificationScreen/buyer_verification_screen.dart';
import '../../VerificationScreen/demand_monitoring_screen.dart';
import '../../VerificationScreen/farmer_verification_screen.dart';
import '../../VerificationScreen/product_approval_screen.dart';

import '../../VerificationScreen/user_detail_modal.dart';
import '../../VerificationScreen/product_detail_admin_modal.dart';
import '../../VerificationScreen/demand_detail_admin_modal.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedTabIndex = 0;

  final List<String> _tabs = [
    'ওভারভিউ',
    'কৃষক যাচাই',
    'ক্রেতা যাচাই',
    'পণ্য অনুমোদন',
    'চাহিদা তদারকি',
    'অর্ডার ট্র্যাকিং',
    'অভিযোগ নিষ্পত্তি',
  ];

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AdminRepository>();

    Widget activeTabWidget;
    switch (_selectedTabIndex) {
      case 0:
        activeTabWidget = const OverviewScreen();
        break;
      case 1:
        activeTabWidget = const FarmerVerificationScreen();
        break;
      case 2:
        activeTabWidget = const BuyerVerificationScreen();
        break;
      case 3:
        activeTabWidget = const ProductApprovalScreen();
        break;
      case 4:
        activeTabWidget = const DemandMonitoringScreen();
        break;
      case 5:
        activeTabWidget = const OrdersScreen();
        break;
      case 6:
        activeTabWidget = const DisputesScreen();
        break;
      default:
        activeTabWidget = const OverviewScreen();
    }

    return Stack(
      children: [
        LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1024;

        if (isDesktop) {
          // Desktop / Laptop View (Sidebar + Main Header + Responsive Content)
          return Scaffold(
            backgroundColor: const Color(0xFFF1F5F9),
            body: Row(
              children: [
                WebSidebar(
                  selectedIndex: _selectedTabIndex,
                  onItemSelected: (index) => setState(() => _selectedTabIndex = index),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const WebHeader(),
                      // Desktop Sub-header Banner
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        color: Colors.white,
                        child: Row(
                          children: [
                            const Icon(Icons.shield_rounded, color: Color(0xFF0284C7), size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'কৃষিবাজার অ্যাডমিন কন্ট্রোল প্যানেল — ${_tabs[_selectedTabIndex]}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const Text(
                                    'রিয়েল-টাইম মার্কেটপ্লেস মনিটরিং ও কন্ট্রোল ব্যবস্থা',
                                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0284C7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'সুপার অ্যাডমিন ড্যাশবোর্ড',
                                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(child: activeTabWidget),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // Mobile Phone / Tablet View (Green Header + Blue Banner + Horizontal Scrollable Tabs)
        return Scaffold(
          backgroundColor: const Color(0xFFF1F5F9),
          body: SafeArea(
            child: Column(
              children: [
                // Top Green Header Bar matching Kotlin Screenshots
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    color: Color(0xFF14532D),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.shield_outlined, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'সুপার অ্যাডমিন',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 20),
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Blue Title Banner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.shield_rounded, color: Color(0xFF0284C7), size: 24),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'কৃষিবাজার অ্যাডমিন কন্ট্রোল প্যানেল',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'সুপার অ্যাডমিন',
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Horizontal Scrollable Tab Pills
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _tabs.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedTabIndex == index;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () => setState(() => _selectedTabIndex = index),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF0284C7) : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF0284C7) : const Color(0xFFCBD5E1),
                              ),
                            ),
                            child: Text(
                              _tabs[index],
                              style: TextStyle(
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),

                // Active Tab Body
                Expanded(child: activeTabWidget),
              ],
            ),
          ),
        );
      },
    ),
    if (repo.activeUserForDetail != null)
      UserDetailModal(user: repo.activeUserForDetail!),
    if (repo.activeProductForDetail != null)
      ProductDetailAdminModal(product: repo.activeProductForDetail!),
    if (repo.activeDemandForDetail != null)
      DemandDetailAdminModal(demand: repo.activeDemandForDetail!),
    ],
    );
  }
}
