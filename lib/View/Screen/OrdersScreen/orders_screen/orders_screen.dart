import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../global/Model/admin_models.dart';
import '../../../../global/controller/admin_repository.dart';
import 'order_tracking_detail_view.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _selectedFilter = 'all';
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminRepository>().fetchOrdersFromBackend();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AdminRepository>();

    // If an order is clicked for detail tracking, render the dedicated step-by-step detail view!
    if (repo.activeOrderForDetail != null) {
      return OrderTrackingDetailView(order: repo.activeOrderForDetail!);
    }

    final allOrders = repo.orders;

    // Search and Filter logic
    final filteredOrders = allOrders.where((order) {
      // Filter by status tab
      bool matchesFilter = true;
      if (_selectedFilter == 'paymentPending') {
        matchesFilter = order.paymentStatus == 'pending_verification' ||
            order.orderStatus == OrderStatus.paymentPending;
      } else if (_selectedFilter == 'qualityPending') {
        matchesFilter = (order.isDepositPaid || order.paymentStatus == 'confirmed') &&
            !order.isQualityVerified &&
            order.isQualityPassed != false &&
            order.orderStatus != OrderStatus.qualityRejected &&
            order.orderStatus != OrderStatus.refunded;
      } else if (_selectedFilter == 'rejectedRefund') {
        matchesFilter = order.isQualityPassed == false ||
            order.orderStatus == OrderStatus.qualityRejected ||
            order.refundStatus == 'pending' ||
            order.orderStatus == OrderStatus.refunded;
      } else if (_selectedFilter == 'verified') {
        matchesFilter = (order.isQualityVerified || order.isQualityPassed == true) &&
            order.orderStatus != OrderStatus.delivered &&
            order.orderStatus != OrderStatus.completed &&
            order.orderStatus != OrderStatus.qualityRejected &&
            order.orderStatus != OrderStatus.refunded;
      } else if (_selectedFilter == 'inTransit') {
        matchesFilter = order.orderStatus == OrderStatus.inTransit ||
            order.transportStatus == 'in_transit' ||
            order.transportStatus == 'inTransit' ||
            order.transportStatus == 'onTheWay';
      } else if (_selectedFilter == 'delivered') {
        matchesFilter = order.orderStatus == OrderStatus.delivered ||
            order.orderStatus == OrderStatus.completed ||
            order.transportStatus == 'delivered';
      }

      if (!matchesFilter) return false;

      // Filter by search query
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.trim().toLowerCase();
        final matchesOrderNum = order.orderNumber.toLowerCase().contains(q);
        final matchesProduct = order.productTitle.toLowerCase().contains(q);
        final matchesFarmer = order.farmerName.toLowerCase().contains(q);
        final matchesBuyer = order.buyerName.toLowerCase().contains(q) ||
            order.buyerBusinessName.toLowerCase().contains(q);
        return matchesOrderNum || matchesProduct || matchesFarmer || matchesBuyer;
      }

      return true;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'অর্ডার ট্র্যাকিং ও হাব কন্ট্রোল ড্যাশবোর্ড',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'চলমান রিয়েল অর্ডারসমূহ, পেমেন্ট যাচাই, পরীক্ষক নিয়োগ ও পরিবহন ট্র্যাকিং (${allOrders.length} টি অর্ডার)',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: repo.isLoadingOrders
                    ? null
                    : () => repo.fetchOrdersFromBackend(),
                icon: repo.isLoadingOrders
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.refresh, size: 18),
                label: const Text('রিফ্রেশ করুন'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF166534),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Search Bar & Stats Row
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'অর্ডার নং (যেমন: KB-89753C), পণ্য বা ক্রেতা/কৃষকের নাম দিয়ে খুঁজুন...',
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Filters row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('সবগুলো (${allOrders.length})', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'পেমেন্ট যাচাই পেন্ডিং (${allOrders.where((o) => o.paymentStatus == 'pending_verification' || o.orderStatus == OrderStatus.paymentPending).length})',
                  'paymentPending',
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'মান যাচাই প্রয়োজন (${allOrders.where((o) => (o.isDepositPaid || o.paymentStatus == 'confirmed') && !o.isQualityVerified && o.isQualityPassed != false).length})',
                  'qualityPending',
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'বাতিল ও রিফান্ড (${allOrders.where((o) => o.isQualityPassed == false || o.orderStatus == OrderStatus.qualityRejected || o.refundStatus == 'pending' || o.orderStatus == OrderStatus.refunded).length})',
                  'rejectedRefund',
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'হাব যাচাই সম্পন্ন (${allOrders.where((o) => (o.isQualityVerified || o.isQualityPassed == true) && o.orderStatus != OrderStatus.qualityRejected).length})',
                  'verified',
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'পরিবহনে চলমান (${allOrders.where((o) => o.orderStatus == OrderStatus.inTransit || o.transportStatus == 'in_transit' || o.transportStatus == 'onTheWay').length})',
                  'inTransit',
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'ডেলিভার্ড (${allOrders.where((o) => o.orderStatus == OrderStatus.delivered || o.orderStatus == OrderStatus.completed).length})',
                  'delivered',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Orders Content: Grid / Cards List
          if (repo.isLoadingOrders && allOrders.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: CircularProgressIndicator(),
              ),
            )
          else if (filteredOrders.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.inbox_outlined, size: 52, color: Color(0xFF94A3B8)),
                  const SizedBox(height: 12),
                  const Text(
                    'কোনো অর্ডার পাওয়া যায়নি',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _searchQuery.isNotEmpty
                        ? 'আপনার সার্চ কুয়েরির সাথে কোনো অর্ডার মিলেনি।'
                        : 'বর্তমান ফিল্টারে কোনো চলমান অর্ডার নেই।',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                // Responsive grid: 2 columns on wide screens, 1 on narrow
                final isWide = constraints.maxWidth >= 900;
                final crossAxisCount = isWide ? 2 : 1;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 18,
                    mainAxisExtent: 260, // Fixed sleek height for compact cards
                  ),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    return _buildCompactOrderCard(context, filteredOrders[index], repo);
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF166534) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF166534) : const Color(0xFFCBD5E1)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF334155),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // COMPACT ORDER CARD (ছোট ছোট কার্ড)
  // -------------------------------------------------------------
  Widget _buildCompactOrderCard(BuildContext context, AdminOrderRecord order, AdminRepository repo) {
    // Current stage text and color
    String stageText = 'ধাপ ১: ডিপোজিট বাকি';
    Color stageBg = const Color(0xFFFEF3C7);
    Color stageCol = const Color(0xFFB45309);

    if (order.orderStatus == OrderStatus.delivered || order.orderStatus == OrderStatus.completed) {
      stageText = 'ধাপ ৪: ডেলিভারি সম্পন্ন';
      stageBg = const Color(0xFFDCFCE7);
      stageCol = const Color(0xFF166534);
    } else if (order.orderStatus == OrderStatus.inTransit ||
        order.transportStatus == 'in_transit' ||
        order.transportStatus == 'onTheWay') {
      stageText = 'ধাপ ৩: পরিবহনে চলমান 🚚';
      stageBg = const Color(0xFFE0F2FE);
      stageCol = const Color(0xFF0369A1);
    } else if (order.isQualityVerified && order.isQualityPassed != false) {
      stageText = 'ধাপ ৩: চালক নির্ধারণ বাকি';
      stageBg = const Color(0xFFF3E8FF);
      stageCol = const Color(0xFF7E22CE);
    } else if (order.isDepositPaid || order.paymentStatus == 'confirmed') {
      stageText = order.inspectorName.isNotEmpty ? 'ধাপ ২: পণ্য পরীক্ষাধীন 🔍' : 'ধাপ ২: পরীক্ষক নিয়োগ বাকি';
      stageBg = const Color(0xFFFEF3C7);
      stageCol = const Color(0xFFD97706);
    }

    return InkWell(
      onTap: () => repo.openOrderDetail(order),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Row 1: Order ID Badge, Creation Time, Stage Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Text(
                        order.orderNumber,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D4ED8),
                        ),
                      ),
                    ),
                    if (order.createdAt.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        order.createdAt,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: stageBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    stageText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: stageCol,
                    ),
                  ),
                ),
              ],
            ),

            // Row 2: Product Name & Quantity
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text('🌾', style: TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.productTitle,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'পরিমাণ: ${order.quantity.toStringAsFixed(0)} ${order.unit} • দর: ৳${order.pricePerUnit.toStringAsFixed(0)}/${order.unit}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Row 3: Parties Info (Farmer & Buyer Summary)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.agriculture, size: 14, color: Color(0xFF166534)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'কৃষক: ${order.farmerName}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 16, color: const Color(0xFFCBD5E1)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.storefront, size: 14, color: Color(0xFF0284C7)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'ক্রেতা: ${order.buyerBusinessName.isNotEmpty ? order.buyerBusinessName : order.buyerName}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Row 4: Total Amount, Deposit Status & Click Action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'মোট মূল্য: ৳ ${order.totalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'ডিপোজিট: ৳ ${order.depositRequired.toStringAsFixed(0)} (${order.isDepositPaid ? 'জমা হয়েছে ✅' : 'বাকি ⏳'})',
                      style: TextStyle(
                        fontSize: 11,
                        color: order.isDepositPaid ? const Color(0xFF166534) : const Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => repo.openOrderDetail(order),
                  icon: const Icon(Icons.arrow_forward, size: 14),
                  label: const Text('বিস্তারিত ট্র্যাকিং'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF166534),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
