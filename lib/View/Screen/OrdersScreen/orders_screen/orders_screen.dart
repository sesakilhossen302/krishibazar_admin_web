import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Utils/AppColors/app_colors.dart';
import '../../../../global/Model/admin_models.dart';
import '../../../../global/controller/admin_repository.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AdminRepository>();
    final allOrders = repo.orders;

    // Filter logic
    final filteredOrders = allOrders.where((order) {
      if (_selectedFilter == 'paymentConfirmed') {
        return order.isDepositPaid && !order.isQualityVerified;
      }
      if (_selectedFilter == 'qualityPending') {
        return order.isDepositPaid && !order.isQualityVerified;
      }
      if (_selectedFilter == 'verified') {
        return order.isQualityVerified &&
            order.orderStatus != OrderStatus.delivered &&
            order.orderStatus != OrderStatus.completed;
      }
      if (_selectedFilter == 'inTransit') {
        return order.orderStatus == OrderStatus.inTransit ||
            order.transportStatus == 'in_transit' ||
            order.transportStatus == 'inTransit';
      }
      if (_selectedFilter == 'delivered') {
        return order.orderStatus == OrderStatus.delivered ||
            order.orderStatus == OrderStatus.completed ||
            order.transportStatus == 'delivered';
      }
      return true;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
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
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'কালেকশন হাবে পণ্যের গুণমান ও ওজন পরীক্ষা এবং পরিবহন নিয়ন্ত্রণ করুন (${allOrders.length} টি অর্ডার)',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Filters row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('সবগুলো (${allOrders.length})', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'যাচাই প্রয়োজন (${allOrders.where((o) => o.isDepositPaid && !o.isQualityVerified).length})',
                  'qualityPending',
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'হাব যাচাই সম্পন্ন (${allOrders.where((o) => o.isQualityVerified).length})',
                  'verified',
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'পরিবহনে চলমান (${allOrders.where((o) => o.orderStatus == OrderStatus.inTransit || o.transportStatus == 'in_transit').length})',
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
          const SizedBox(height: 20),

          // Orders List
          if (repo.isLoadingOrders && allOrders.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
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
                children: const [
                  Icon(Icons.inbox_outlined, size: 48, color: Color(0xFF94A3B8)),
                  SizedBox(height: 12),
                  Text(
                    'কোনো অর্ডার পাওয়া যায়নি',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredOrders.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildOrderCard(context, filteredOrders[index], repo);
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

  Widget _buildOrderCard(BuildContext context, AdminOrderRecord order, AdminRepository repo) {
    // Badge configuration
    Color statusBg = const Color(0xFFF1F5F9);
    Color statusCol = const Color(0xFF475569);
    switch (order.orderStatus) {
      case OrderStatus.completed:
      case OrderStatus.delivered:
        statusBg = const Color(0xFFDCFCE7);
        statusCol = const Color(0xFF166534);
        break;
      case OrderStatus.inTransit:
        statusBg = const Color(0xFFE0F2FE);
        statusCol = const Color(0xFF0369A1);
        break;
      case OrderStatus.collectionVerified:
        statusBg = const Color(0xFFE0E7FF);
        statusCol = const Color(0xFF4338CA);
        break;
      case OrderStatus.paymentConfirmed:
        statusBg = const Color(0xFFFEF3C7);
        statusCol = const Color(0xFFB45309);
        break;
      default:
        statusBg = const Color(0xFFFFEDD5);
        statusCol = const Color(0xFFEA580C);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
          // Order Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBF5EC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFC7E0CB)),
                    ),
                    child: Text(
                      order.orderNumber,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF166534),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    order.createdAt.isNotEmpty ? 'তারিখ: ${order.createdAt}' : '',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ],
              ),

              // Badges
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: order.isDepositPaid ? const Color(0xFFDCFCE7) : const Color(0xFFFFEDD5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      order.isDepositPaid ? '💰 ডিপোজিট পেইড' : '⏳ ডিপোজিট বাকি',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: order.isDepositPaid ? const Color(0xFF166534) : const Color(0xFFEA580C),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      order.orderStatus.labelBn,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusCol,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Product & Trade Details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.productTitle,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'পরিমাণ: ${order.quantity.toStringAsFixed(0)} ${order.unit} • একক দর: ৳${order.pricePerUnit.toStringAsFixed(0)} • মোট মূল্য: ৳${order.totalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF166534),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '👨‍🌾 কৃষক: ${order.farmerName} (${order.farmerPhone})',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF334155), fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '🏬 পাইকার/ক্রেতা: ${order.buyerName} (${order.buyerPhone})',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF334155), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),

          // Quality Verification & Transport Status Grid
          LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 700;
            final verificationWidget = Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: order.isQualityVerified ? const Color(0xFFF0FDF4) : const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: order.isQualityVerified ? const Color(0xFFBBF7D0) : const Color(0xFFFDE68A),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '⚖️ ওজন ও গুণমান যাচাই',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: order.isQualityVerified ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          order.isQualityVerified ? 'যাচাই সম্পন্ন ✅' : 'যাচাই বাকি 🧪',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: order.isQualityVerified ? const Color(0xFF166534) : const Color(0xFFB45309),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (order.isQualityVerified) ...[
                    Text('প্রকৃত মাপা ওজন: ${order.actualWeight?.toStringAsFixed(0) ?? order.quantity.toStringAsFixed(0)} ${order.unit}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF166534))),
                    Text('গ্রেড: ${order.qualityGrade} • ইন্সপেক্টর: ${order.verifiedBy}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
                    Text('মন্তব্য: "${order.verificationNotes}"',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontStyle: FontStyle.italic)),
                  ] else ...[
                    const Text('কালেকশন হাবে পণ্য আসলে ওজন ও কোয়ালিটি টেস্ট সম্পন্ন করুন।',
                        style: TextStyle(fontSize: 12, color: Color(0xFF92400E))),
                  ],
                ],
              ),
            );

            final transportWidget = Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '🚚 পরিবহন ও ট্র্যাকিং',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          order.transportStatusText,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0369A1),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('ড্রাইভার: ${order.driverName} (${order.driverPhone})',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF334155))),
                  Text('গাড়ির নম্বর: ${order.vehicleNumber}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
                  Text('গন্তব্য: ${order.deliveryLocation}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ],
              ),
            );

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: verificationWidget),
                  const SizedBox(width: 14),
                  Expanded(child: transportWidget),
                ],
              );
            } else {
              return Column(
                children: [
                  verificationWidget,
                  const SizedBox(height: 10),
                  transportWidget,
                ],
              );
            }
          }),
          const SizedBox(height: 16),

          // Action Buttons: Admin Controls
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              // 1. Verify Quality Button
              ElevatedButton.icon(
                onPressed: () => _openQualityVerificationDialog(context, order, repo),
                icon: const Icon(Icons.fact_check_outlined, size: 16),
                label: Text(order.isQualityVerified ? 'গুণমান পুনঃপরীক্ষা ⚖️' : 'ওজন ও গুণমান পরীক্ষা 🧪'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: order.isQualityVerified ? const Color(0xFF0F766E) : const Color(0xFFD97706),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),

              // 2. Transport & Driver Update
              OutlinedButton.icon(
                onPressed: () => _openTransportUpdateDialog(context, order, repo),
                icon: const Icon(Icons.local_shipping_outlined, size: 16, color: Color(0xFF0284C7)),
                label: const Text('পরিবহন ও ড্রাইভার আপডেট 🚚', style: TextStyle(color: Color(0xFF0284C7))),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  side: const BorderSide(color: Color(0xFF0284C7)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),

              // 3. Mark in-transit / delivered quick status
              PopupMenuButton<String>(
                onSelected: (newStatus) async {
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  final success = await repo.updateOrderStatus(orderId: order.id, status: newStatus);
                  if (context.mounted) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text(success ? 'স্ট্যাটাস সফলভাবে আপডেট হয়েছে' : 'আপডেট ব্যর্থ হয়েছে'),
                        backgroundColor: success ? const Color(0xFF166534) : Colors.red,
                      ),
                    );
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'paymentConfirmed', child: Text('পেমেন্ট কনফার্মড')),
                  const PopupMenuItem(value: 'collectionVerified', child: Text('হাব যাচাই সম্পন্ন')),
                  const PopupMenuItem(value: 'inTransit', child: Text('ইন ট্রানজিট (পথে আছে)')),
                  const PopupMenuItem(value: 'delivered', child: Text('ডেলিভারি সম্পন্ন 🎉')),
                  const PopupMenuItem(value: 'completed', child: Text('অর্ডার সমাপ্ত (Completed)')),
                  const PopupMenuItem(value: 'cancelled', child: Text('অর্ডার বাতিল')),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.tune, size: 16, color: Color(0xFF334155)),
                      SizedBox(width: 6),
                      Text(
                        'স্ট্যাটাস পরিবর্তন',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                      ),
                      Icon(Icons.arrow_drop_down, size: 18, color: Color(0xFF334155)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Quality Verification Dialog
  void _openQualityVerificationDialog(BuildContext context, AdminOrderRecord order, AdminRepository repo) {
    final weightController = TextEditingController(
      text: (order.actualWeight ?? order.quantity).toStringAsFixed(0),
    );
    final inspectorController = TextEditingController(
      text: order.verifiedBy.isNotEmpty ? order.verifiedBy : 'সেলিম রেজা (কালেকশন হাব ইনস্পেক্টর)',
    );
    final notesController = TextEditingController(
      text: order.verificationNotes.isNotEmpty ? order.verificationNotes : 'পণ্য ফ্রেশ ও সম্পূর্ণ মানসম্মত',
    );
    String selectedGrade = order.qualityGrade.isNotEmpty ? order.qualityGrade : 'গ্রেড A (প্রিমিয়াম মান)';

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.fact_check, color: Color(0xFF166534)),
              SizedBox(width: 8),
              Text('পণ্যের ওজন ও গুণমান যাচাই (Hub Test)', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'অর্ডার নং: ${order.orderNumber} • ${order.productTitle}',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'চুক্তিকৃত পরিমাণ: ${order.quantity.toStringAsFixed(0)} ${order.unit}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                  ),
                  const Divider(height: 24),

                  // Actual Weight Field
                  const Text('প্রকৃত মাপা ওজন:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: 'যেমন: ${order.quantity}',
                      suffixText: order.unit,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Quality Grade Dropdown
                  const Text('যাচাইকৃত পণ্যের গ্রেড:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: selectedGrade,
                    items: const [
                      DropdownMenuItem(value: 'গ্রেড A (প্রিমিয়াম মান)', child: Text('গ্রেড A (প্রিমিয়াম মান)')),
                      DropdownMenuItem(value: 'গ্রেড B (সাধারণ মান)', child: Text('গ্রেড B (সাধারণ মান)')),
                      DropdownMenuItem(value: 'জৈব / অর্গানিক', child: Text('জৈব / অর্গানিক')),
                    ],
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedGrade = val);
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Inspector Name Field
                  const Text('যাচাইকারী ইন্সপেক্টর:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: inspectorController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Notes Field
                  const Text('ইন্সপেকশন নোট / মন্তব্য:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: notesController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('বাতিল'),
            ),
            ElevatedButton(
              onPressed: () async {
                final double actWeight = double.tryParse(weightController.text.trim()) ?? order.quantity;
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                Navigator.pop(dialogCtx);

                final success = await repo.verifyOrderQuality(
                  orderId: order.id,
                  actualWeight: actWeight,
                  qualityGrade: selectedGrade,
                  verifiedBy: inspectorController.text.trim(),
                  verificationNotes: notesController.text.trim(),
                );

                if (context.mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? '✅ মান ও ওজন পরীক্ষা সম্পন্ন! স্ট্যাটাস "হাব যাচাই সম্পন্ন" হয়েছে।'
                            : '❌ আপডেট ব্যর্থ হয়েছে',
                      ),
                      backgroundColor: success ? const Color(0xFF166534) : Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF166534),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('যাচাই সম্পন্ন ও নিশ্চিত করুন'),
            ),
          ],
        ),
      ),
    );
  }

  // Transport Update Dialog
  void _openTransportUpdateDialog(BuildContext context, AdminOrderRecord order, AdminRepository repo) {
    final driverNameController = TextEditingController(text: order.driverName);
    final driverPhoneController = TextEditingController(text: order.driverPhone);
    final vehicleNumberController = TextEditingController(text: order.vehicleNumber);
    String selectedTransportStatus = order.transportStatus.isNotEmpty ? order.transportStatus : 'waiting';

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.local_shipping, color: Color(0xFF0284C7)),
              SizedBox(width: 8),
              Text('পরিবহন ও ড্রাইভার আপডেট', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('অর্ডার নং: ${order.orderNumber} • গন্তব্য: ${order.deliveryLocation}',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                  const Divider(height: 24),

                  const Text('ড্রাইভারের নাম:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: driverNameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 14),

                  const Text('ড্রাইভারের ফোন নম্বর:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: driverPhoneController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 14),

                  const Text('গাড়ির নম্বর:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: vehicleNumberController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 14),

                  const Text('পরিবহন বর্তমান অগ্রগতি:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: selectedTransportStatus,
                    items: const [
                      DropdownMenuItem(value: 'waiting', child: Text('পিকআপের অপেক্ষায় (Waiting)')),
                      DropdownMenuItem(value: 'in_transit', child: Text('ইন ট্রানজিট - পথে আছে 🚚')),
                      DropdownMenuItem(value: 'delivered', child: Text('গন্তব্যে পৌঁছেছে - ডেলিভার্ড 🎉')),
                    ],
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedTransportStatus = val);
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('বাতিল'),
            ),
            ElevatedButton(
              onPressed: () async {
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                Navigator.pop(dialogCtx);

                final success = await repo.updateOrderTransport(
                  orderId: order.id,
                  driverName: driverNameController.text.trim(),
                  driverPhone: driverPhoneController.text.trim(),
                  vehicleNumber: vehicleNumberController.text.trim(),
                  transportStatus: selectedTransportStatus,
                );

                if (context.mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        success ? '✅ পরিবহন তথ্য সফলভাবে আপডেট হয়েছে!' : '❌ পরিবহন তথ্য আপডেট ব্যর্থ হয়েছে',
                      ),
                      backgroundColor: success ? const Color(0xFF166534) : Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('আপডেট সংরক্ষণ করুন'),
            ),
          ],
        ),
      ),
    );
  }
}
