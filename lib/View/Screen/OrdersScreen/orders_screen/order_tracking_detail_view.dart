import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../global/Model/admin_models.dart';
import '../../../../global/controller/admin_repository.dart';

class OrderTrackingDetailView extends StatefulWidget {
  final AdminOrderRecord order;

  const OrderTrackingDetailView({
    super.key,
    required this.order,
  });

  @override
  State<OrderTrackingDetailView> createState() => _OrderTrackingDetailViewState();
}

class _OrderTrackingDetailViewState extends State<OrderTrackingDetailView> {
  // Step 1 Controllers
  final TextEditingController _paymentNotesCtrl = TextEditingController();

  // Step 2 Controllers
  final TextEditingController _inspectorNameCtrl = TextEditingController();
  final TextEditingController _inspectorDesigCtrl = TextEditingController();
  final TextEditingController _actualWeightCtrl = TextEditingController();
  final TextEditingController _inspectionNotesCtrl = TextEditingController();
  final TextEditingController _rejectionReasonCtrl = TextEditingController();
  String _selectedGrade = 'গ্রেড A (প্রিমিয়াম মান)';
  bool _chkWeight = true;
  bool _chkFreshness = true;
  bool _chkPestFree = true;
  bool _chkPackaging = true;

  // Step 3 Controllers
  final TextEditingController _driverNameCtrl = TextEditingController();
  final TextEditingController _driverPhoneCtrl = TextEditingController();
  final TextEditingController _vehicleNumCtrl = TextEditingController();
  final TextEditingController _transportAgencyCtrl = TextEditingController();

  // Step 4 Controllers
  final TextEditingController _payoutTrxCtrl = TextEditingController();
  final TextEditingController _payoutNotesCtrl = TextEditingController();

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initFields(widget.order);
  }

  @override
  void didUpdateWidget(covariant OrderTrackingDetailView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.order != widget.order) {
      _initFields(widget.order);
    }
  }

  void _initFields(AdminOrderRecord o) {
    if (o.inspectorName.isNotEmpty) {
      _inspectorNameCtrl.text = o.inspectorName;
    } else {
      _inspectorNameCtrl.text = 'মো: সেলিম রেজা';
    }

    if (o.inspectorDesignation.isNotEmpty) {
      _inspectorDesigCtrl.text = o.inspectorDesignation;
    } else {
      _inspectorDesigCtrl.text = 'সিনিয়র কোয়ালিটি অফিসার (কালেকশন হাব)';
    }

    if (o.actualWeight != null && o.actualWeight! > 0) {
      _actualWeightCtrl.text = o.actualWeight!.toString();
    } else {
      _actualWeightCtrl.text = o.quantity.toString();
    }

    if (o.driverName.isNotEmpty) _driverNameCtrl.text = o.driverName;
    if (o.driverPhone.isNotEmpty) _driverPhoneCtrl.text = o.driverPhone;
    if (o.vehicleNumber.isNotEmpty) _vehicleNumCtrl.text = o.vehicleNumber;
    if (o.transportAgency.isNotEmpty) _transportAgencyCtrl.text = o.transportAgency;
  }

  @override
  void dispose() {
    _paymentNotesCtrl.dispose();
    _inspectorNameCtrl.dispose();
    _inspectorDesigCtrl.dispose();
    _actualWeightCtrl.dispose();
    _inspectionNotesCtrl.dispose();
    _rejectionReasonCtrl.dispose();
    _driverNameCtrl.dispose();
    _driverPhoneCtrl.dispose();
    _vehicleNumCtrl.dispose();
    _transportAgencyCtrl.dispose();
    _payoutTrxCtrl.dispose();
    _payoutNotesCtrl.dispose();
    super.dispose();
  }

  // Determine sequential milestone completion
  bool get _isStep1Done =>
      widget.order.isDepositPaid ||
      widget.order.paymentStatus == 'confirmed' ||
      widget.order.orderStatus != OrderStatus.pending &&
          widget.order.orderStatus != OrderStatus.paymentPending;

  bool get _isInspectorAssigned =>
      widget.order.inspectorName.trim().isNotEmpty;

  bool get _isStep2Done =>
      widget.order.isQualityVerified && widget.order.isQualityPassed != false;

  bool get _isStep3Done =>
      widget.order.orderStatus == OrderStatus.inTransit ||
      widget.order.orderStatus == OrderStatus.delivered ||
      widget.order.orderStatus == OrderStatus.completed ||
      widget.order.transportStatus == 'in_transit' ||
      widget.order.transportStatus == 'inTransit' ||
      widget.order.transportStatus == 'onTheWay' ||
      widget.order.transportStatus == 'delivered';

  bool get _isStep4Delivered =>
      widget.order.orderStatus == OrderStatus.delivered ||
      widget.order.orderStatus == OrderStatus.completed ||
      widget.order.transportStatus == 'delivered';

  bool get _isStep4PayoutDone =>
      widget.order.farmerPayoutStatus == 'completed' ||
      widget.order.farmerPayoutStatus == 'paid';

  int get _currentStepNumber {
    if (!_isStep1Done) return 1;
    if (!_isStep2Done) return 2;
    if (!_isStep3Done) return 3;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AdminRepository>();
    final o = widget.order;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Navigation Bar
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => repo.closeOrderDetail(),
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('সকল অর্ডারে ফিরুন'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF166534),
                  side: const BorderSide(color: Color(0xFF166534)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.tag, size: 16, color: Color(0xFF1D4ED8)),
                    const SizedBox(width: 4),
                    Text(
                      o.orderNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D4ED8),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _isProcessing
                    ? null
                    : () async {
                        setState(() => _isProcessing = true);
                        await repo.fetchOrdersFromBackend();
                        setState(() => _isProcessing = false);
                      },
                icon: _isProcessing
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.refresh, size: 16),
                label: const Text('লাইভ রিফ্রেশ'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Order Main Summary Card
          _buildOrderHeaderSummaryCard(o),
          const SizedBox(height: 24),

          // 4-Step Process Timeline Stepper
          _buildStepTimeline(),
          const SizedBox(height: 28),

          // STEP 1 CARD
          _buildStep1Card(repo, o),
          const SizedBox(height: 24),

          // STEP 2 CARD
          _buildStep2Card(repo, o),
          const SizedBox(height: 24),

          // STEP 3 CARD
          _buildStep3Card(repo, o),
          const SizedBox(height: 24),

          // STEP 4 CARD
          _buildStep4Card(repo, o),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // ORDER HEADER SUMMARY CARD
  // -------------------------------------------------------------
  Widget _buildOrderHeaderSummaryCard(AdminOrderRecord o) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('🌾', style: TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      o.productTitle,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 12,
                      runSpacing: 6,
                      children: [
                        _buildMetaChip(Icons.category, 'ক্যাটাগরি: ${o.category}'),
                        _buildMetaChip(Icons.scale, 'পরিমাণ: ${o.quantity.toStringAsFixed(0)} ${o.unit}'),
                        _buildMetaChip(Icons.payments_outlined, 'একক দর: ৳${o.pricePerUnit.toStringAsFixed(0)}/${o.unit}'),
                        if (o.createdAt.isNotEmpty)
                          _buildMetaChip(Icons.access_time, 'অর্ডার তারিখ: ${o.createdAt}'),
                      ],
                    ),
                  ],
                ),
              ),
              _buildOrderStatusBadge(o),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(color: Color(0xFFF1F5F9), height: 1),
          const SizedBox(height: 18),

          // Parties & Financial Breakdown Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 760;
              return isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildPartyInfoCard(isFarmer: true, order: o)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildPartyInfoCard(isFarmer: false, order: o)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildFinancialSummaryBox(o)),
                      ],
                    )
                  : Column(
                      children: [
                        _buildPartyInfoCard(isFarmer: true, order: o),
                        const SizedBox(height: 12),
                        _buildPartyInfoCard(isFarmer: false, order: o),
                        const SizedBox(height: 12),
                        _buildFinancialSummaryBox(o),
                      ],
                    );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetaChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFF64748B)),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
        ],
      ),
    );
  }

  Widget _buildPartyInfoCard({required bool isFarmer, required AdminOrderRecord order}) {
    final title = isFarmer ? 'উৎপাদক / কৃষক' : 'ক্রেতা / পাইকারি আড়ত';
    final name = isFarmer ? order.farmerName : (order.buyerBusinessName.isNotEmpty ? order.buyerBusinessName : order.buyerName);
    final subName = isFarmer ? order.farmerLocation : order.buyerName;
    final phone = isFarmer ? order.farmerPhone : order.buyerPhone;
    final location = isFarmer ? order.farmerLocation : order.deliveryLocation;
    final icon = isFarmer ? Icons.agriculture : Icons.storefront;
    final color = isFarmer ? const Color(0xFF166534) : const Color(0xFF0284C7);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subName.isNotEmpty && subName != name)
            Text(subName, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.phone, size: 12, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Text(phone.isNotEmpty ? phone : 'যোগাযোগ নম্বর নেই', style: const TextStyle(fontSize: 12, color: Color(0xFF334155))),
            ],
          ),
          if (location.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    location,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFinancialSummaryBox(AdminOrderRecord o) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.account_balance_wallet, size: 16, color: Color(0xFF166534)),
              SizedBox(width: 6),
              Text('আর্থিক হিসাব বিবরণী', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF166534))),
            ],
          ),
          const SizedBox(height: 8),
          _buildFinancialRow('মোট পণ্য মূল্য:', '৳ ${o.totalAmount.toStringAsFixed(0)}', isBold: true),
          const SizedBox(height: 4),
          _buildFinancialRow('২০% জামানত ডিপোজিট:', '৳ ${o.depositRequired.toStringAsFixed(0)}',
              highlightColor: o.isDepositPaid ? const Color(0xFF166534) : const Color(0xFFDC2626)),
          const SizedBox(height: 4),
          _buildFinancialRow('কৃষিবাজার ফি (৫%):', '৳ ${(o.totalAmount * 0.05).toStringAsFixed(0)}'),
          const Divider(height: 10, color: Color(0xFFDCFCE7)),
          _buildFinancialRow('কৃষকের প্রাপ্য (৯৫%):', '৳ ${o.farmerPayoutAmount > 0 ? o.farmerPayoutAmount.toStringAsFixed(0) : (o.totalAmount * 0.95).toStringAsFixed(0)}',
              isBold: true, highlightColor: const Color(0xFF166534)),
        ],
      ),
    );
  }

  Widget _buildFinancialRow(String label, String value, {bool isBold = false, Color? highlightColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: highlightColor ?? const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderStatusBadge(AdminOrderRecord o) {
    String label = o.orderStatus.labelBn;
    Color bg = const Color(0xFFF1F5F9);
    Color col = const Color(0xFF475569);

    if (o.orderStatus == OrderStatus.inTransit) {
      bg = const Color(0xFFE0F2FE);
      col = const Color(0xFF0369A1);
    } else if (o.orderStatus == OrderStatus.delivered || o.orderStatus == OrderStatus.completed) {
      bg = const Color(0xFFDCFCE7);
      col = const Color(0xFF166534);
    } else if (o.isDepositPaid || o.paymentStatus == 'confirmed') {
      bg = const Color(0xFFFEF3C7);
      col = const Color(0xFFB45309);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: col.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: col),
      ),
    );
  }

  // -------------------------------------------------------------
  // 4-STEP PROGRESS TIMELINE
  // -------------------------------------------------------------
  Widget _buildStepTimeline() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.timeline, size: 18, color: Color(0xFF166534)),
              const SizedBox(width: 8),
              const Text(
                'ধাপে ধাপে ট্র্যাকিং অগ্রগতি',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const Spacer(),
              Text(
                'বর্তমান পর্যায়: ধাপ $_currentStepNumber/৪',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTimelineItem(
                  stepNum: '১',
                  title: 'ডিপোজিট ও পেমেন্ট',
                  subtitle: _isStep1Done ? 'নিশ্চিত ✅' : 'অপেক্ষমাণ ⏳',
                  isCompleted: _isStep1Done,
                  isActive: _currentStepNumber == 1,
                ),
              ),
              _buildTimelineDivider(_isStep1Done),
              Expanded(
                child: _buildTimelineItem(
                  stepNum: '২',
                  title: 'পরীক্ষক ও মান যাচাই',
                  subtitle: _isStep2Done ? 'পাস ✅' : (_isInspectorAssigned ? 'পরীক্ষাধীন 🔍' : 'নিয়োগ বাকি'),
                  isCompleted: _isStep2Done,
                  isActive: _currentStepNumber == 2,
                ),
              ),
              _buildTimelineDivider(_isStep2Done),
              Expanded(
                child: _buildTimelineItem(
                  stepNum: '৩',
                  title: 'পরিবহন ও ড্রাইভার',
                  subtitle: _isStep3Done ? 'চলমান 🚚' : 'বরাদ্দ বাকি',
                  isCompleted: _isStep3Done,
                  isActive: _currentStepNumber == 3,
                ),
              ),
              _buildTimelineDivider(_isStep3Done),
              Expanded(
                child: _buildTimelineItem(
                  stepNum: '৪',
                  title: 'ডেলিভারি ও পেআউট',
                  subtitle: _isStep4PayoutDone ? 'পরিশোধিত 💸' : (_isStep4Delivered ? 'ডেলিভার্ড 📦' : 'বাকি'),
                  isCompleted: _isStep4PayoutDone,
                  isActive: _currentStepNumber == 4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required String stepNum,
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isActive,
  }) {
    Color circleBg = const Color(0xFFF1F5F9);
    Color circleBorder = const Color(0xFFCBD5E1);
    Color textColor = const Color(0xFF64748B);
    Widget iconWidget = Text(stepNum, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor));

    if (isCompleted) {
      circleBg = const Color(0xFFDCFCE7);
      circleBorder = const Color(0xFF166534);
      iconWidget = const Icon(Icons.check, size: 16, color: Color(0xFF166534));
    } else if (isActive) {
      circleBg = const Color(0xFFFEF3C7);
      circleBorder = const Color(0xFFD97706);
      textColor = const Color(0xFFB45309);
      iconWidget = Text(stepNum, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFB45309)));
    }

    return Column(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: circleBg,
            shape: BoxShape.circle,
            border: Border.all(color: circleBorder, width: 2),
          ),
          child: Center(child: iconWidget),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive || isCompleted ? FontWeight.bold : FontWeight.normal,
            color: isActive ? const Color(0xFF0F172A) : const Color(0xFF475569),
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 11,
            color: isCompleted
                ? const Color(0xFF166534)
                : (isActive ? const Color(0xFFD97706) : const Color(0xFF94A3B8)),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTimelineDivider(bool isCompleted) {
    return Container(
      width: 36,
      height: 2,
      margin: const EdgeInsets.only(bottom: 24),
      color: isCompleted ? const Color(0xFF166534) : const Color(0xFFE2E8F0),
    );
  }

  // -------------------------------------------------------------
  // STEP 1 CARD: DEPOSIT & PAYMENT VERIFICATION
  // -------------------------------------------------------------
  Widget _buildStep1Card(AdminRepository repo, AdminOrderRecord o) {
    final isDone = _isStep1Done;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone ? const Color(0xFFBBF7D0) : const Color(0xFFFDE68A),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: isDone ? const Color(0xFFF0FDF4) : const Color(0xFFFFFBEB),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isDone ? const Color(0xFF166534) : const Color(0xFFD97706),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    isDone ? '✓' : '১',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'ধাপ ১: ২০% জামানত ডিপোজিট যাচাই ও পেমেন্ট প্রাপ্তি নিশ্চিতকরণ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDone ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isDone ? 'পেমেন্ট নিশ্চিত হয়েছে ✅' : 'যাচাই পেন্ডিং ⏳',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDone ? const Color(0xFF166534) : const Color(0xFFB45309),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(20),
            child: isDone
                ? Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Color(0xFF166534), size: 28),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ক্রেতার ২০% জামানত বাবদ ৳ ${o.depositRequired.toStringAsFixed(2)} কৃষিবাজারের তহবিলে সফলভাবে জমা হয়েছে।',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF166534),
                                ),
                              ),
                              if (o.paymentVerificationNotes.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'ভেরিফিকেশন নোট: ${o.paymentVerificationNotes}',
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: Color(0xFFD97706), size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'ক্রেতা ${o.buyerName} ২০% সিকিউরিটি ডিপোজিট (৳ ${o.depositRequired.toStringAsFixed(2)}) জমা দেওয়ার অনুরোধ পাঠিয়েছেন। অ্যাডমিন হিসেবে ব্যাংকে/মোবাইল ব্যাংকিংয়ে টাকা প্রাপ্তি নিশ্চিত করে নিচের বাটনে ক্লিক করুন।',
                                style: const TextStyle(fontSize: 13, color: Color(0xFF92400E)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _paymentNotesCtrl,
                        decoration: const InputDecoration(
                          labelText: 'অ্যাডমিন নোট / ট্রানজেকশন রেফারেন্স (ঐচ্ছিক)',
                          hintText: 'যেমন: বিকাশ মার্চেন্ট ট্রানজেকশন আইডি #TX928374',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _isProcessing
                            ? null
                            : () async {
                                setState(() => _isProcessing = true);
                                final ok = await repo.confirmOrderPayment(
                                  orderId: o.id,
                                  notes: _paymentNotesCtrl.text.trim().isNotEmpty
                                      ? _paymentNotesCtrl.text.trim()
                                      : 'টাকা প্রাপ্তি নিশ্চিত হয়েছে - অ্যাডমিন ভেরিফাইড',
                                );
                                setState(() => _isProcessing = false);
                                if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(ok
                                          ? '✅ ডিপোজিট পেমেন্ট কনফার্ম করা হয়েছে! ধাপ ২ আনলক হয়েছে।'
                                          : '❌ পেমেন্ট নিশ্চিতকরণে সমস্যা হয়েছে। আবার চেষ্টা করুন।'),
                                      backgroundColor: ok ? const Color(0xFF166534) : Colors.red,
                                    ),
                                  );
                              },
                        icon: _isProcessing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.verified, size: 18),
                        label: const Text('হ্যাঁ, টাকা পেয়েছি — পেমেন্ট প্রাপ্তি নিশ্চিত করুন'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF166534),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // STEP 2 CARD: QUALITY INSPECTOR ASSIGNMENT & CHECK
  // -------------------------------------------------------------
  Widget _buildStep2Card(AdminRepository repo, AdminOrderRecord o) {
    final isLocked = !_isStep1Done;
    final isPassed = _isStep2Done;
    final hasInspector = _isInspectorAssigned;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLocked
              ? const Color(0xFFE2E8F0)
              : (isPassed ? const Color(0xFFBBF7D0) : const Color(0xFFBAE6FD)),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: isLocked
                  ? const Color(0xFFF8FAFC)
                  : (isPassed ? const Color(0xFFF0FDF4) : const Color(0xFFF0F9FF)),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isLocked
                        ? const Color(0xFF94A3B8)
                        : (isPassed ? const Color(0xFF166534) : const Color(0xFF0284C7)),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    isPassed ? '✓' : '২',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'ধাপ ২: পরীক্ষক নিয়োগ ও পণ্যের গুণমান ও ওজন পরীক্ষা',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const Spacer(),
                if (isLocked)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('লকড 🔒', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPassed ? const Color(0xFFDCFCE7) : const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isPassed ? 'মান যাচাই সম্পন্ন ✅' : (hasInspector ? 'পরীক্ষাধীন 🔬' : 'পরীক্ষক নিয়োগ বাকি'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isPassed ? const Color(0xFF166534) : const Color(0xFF0284C7),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(20),
            child: isLocked
                ? _buildLockedPlaceholder('ধাপ ১ (পেমেন্ট নিশ্চিতকরণ) সম্পন্ন হলে এই ধাপটি আনলক হবে।')
                : (isPassed
                    ? Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified_outlined, color: Color(0xFF166534), size: 30),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'গুণমান ও ওজন যাচাই সফলভাবে সম্পন্ন হয়েছে!',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF166534),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'প্রকৃত ওজন: ${o.actualWeight ?? o.quantity} ${o.unit} | গ্রেড: ${o.qualityGrade} | পরীক্ষক: ${o.inspectorName} (${o.inspectorDesignation})',
                                    style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
                                  ),
                                  if (o.verificationNotes.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        'মন্তব্য: ${o.verificationNotes}',
                                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // SUB-STAGE 2A: Inspector Assignment
                          if (!hasInspector) ...[
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F9FF),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFBAE6FD)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.person_add_alt_1, color: Color(0xFF0284C7), size: 22),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'কালেকশন হাবে পণ্য পরীক্ষা করার জন্য একজন কোয়ালিটি কন্ট্রোল অফিসার / পরীক্ষকের নাম লিখুন:',
                                      style: TextStyle(fontSize: 13, color: Color(0xFF0369A1), fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: TextFormField(
                                    controller: _inspectorNameCtrl,
                                    decoration: const InputDecoration(
                                      labelText: 'পরীক্ষকের নাম *',
                                      hintText: 'যেমন: সেলিম রেজা',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.person_outline),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 3,
                                  child: TextFormField(
                                    controller: _inspectorDesigCtrl,
                                    decoration: const InputDecoration(
                                      labelText: 'পদবি ও হাব সেন্টার',
                                      hintText: 'সিনিয়র কোয়ালিটি অফিসার (কালেকশন হাব)',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.badge_outlined),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            ElevatedButton.icon(
                              onPressed: _isProcessing
                                  ? null
                                  : () async {
                                      final name = _inspectorNameCtrl.text.trim();
                                      if (name.isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('অনুগ্রহ করে পরীক্ষকের নাম লিখুন।')),
                                        );
                                        return;
                                      }
                                      setState(() => _isProcessing = true);
                                      final ok = await repo.assignOrderInspector(
                                        orderId: o.id,
                                        inspectorName: name,
                                        inspectorDesignation: _inspectorDesigCtrl.text.trim(),
                                      );
                                      setState(() => _isProcessing = false);
                                      if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(ok
                                                ? '✅ পরীক্ষক নিযুক্ত করা হয়েছে! কোয়ালিটি চেকিং কার্ড চালু হয়েছে।'
                                                : '❌ পরীক্ষক নিয়োগে সমস্যা হয়েছে।'),
                                            backgroundColor: ok ? const Color(0xFF166534) : Colors.red,
                                          ),
                                        );
                                    },
                              icon: const Icon(Icons.assignment_ind, size: 18),
                              label: const Text('পরীক্ষক নিয়োগ করুন ও চেকলিস্ট খুলুন'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0284C7),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ] else ...[
                            // Inspector Assigned Header Banner
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFBBF7D0)),
                              ),
                              child: Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 14,
                                    backgroundColor: Color(0xFF166534),
                                    child: Icon(Icons.person, size: 16, color: Colors.white),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'নিযুক্ত পরীক্ষক: ${o.inspectorName} (${o.inspectorDesignation.isNotEmpty ? o.inspectorDesignation : 'কোয়ালিটি কন্ট্রোল'})',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF166534)),
                                  ),
                                  const Spacer(),
                                  TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _inspectorNameCtrl.clear();
                                      });
                                    },
                                    icon: const Icon(Icons.edit, size: 14),
                                    label: const Text('পরিবর্তন', style: TextStyle(fontSize: 12)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),

                            // SUB-STAGE 2B: Live Quality Checklist & Measurements
                            const Text(
                              'লাইভ কোয়ালিটি চেকলিস্ট ও ওজন পরিমাপ:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _actualWeightCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'প্রকৃত পরিমাপকৃত ওজন (${o.unit}) *',
                                      border: const OutlineInputBorder(),
                                      prefixIcon: const Icon(Icons.monitor_weight_outlined),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    initialValue: _selectedGrade,
                                    decoration: const InputDecoration(
                                      labelText: 'গুণমান গ্রেড *',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.grade),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    ),
                                    items: const [
                                      DropdownMenuItem(value: 'গ্রেড A (প্রিমিয়াম মান)', child: Text('গ্রেড A (প্রিমিয়াম মান)')),
                                      DropdownMenuItem(value: 'গ্রেড B (সাধারণ মান)', child: Text('গ্রেড B (সাধারণ মান)')),
                                      DropdownMenuItem(value: 'গ্রেড C (মধ্যম মান)', child: Text('গ্রেড C (মধ্যম মান)')),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) setState(() => _selectedGrade = val);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Checklist items
                            Wrap(
                              spacing: 16,
                              runSpacing: 8,
                              children: [
                                _buildCheckboxItem('ওজন সঠিক পাওয়া গেছে', _chkWeight, (v) => setState(() => _chkWeight = v ?? true)),
                                _buildCheckboxItem('সতেজতা ও আর্দ্রতা মানসম্মত', _chkFreshness, (v) => setState(() => _chkFreshness = v ?? true)),
                                _buildCheckboxItem('কীটনাশক/পচা দাগ মুক্ত', _chkPestFree, (v) => setState(() => _chkPestFree = v ?? true)),
                                _buildCheckboxItem('প্যাকেজিং প্রস্তুত', _chkPackaging, (v) => setState(() => _chkPackaging = v ?? true)),
                              ],
                            ),
                            const SizedBox(height: 14),

                            TextFormField(
                              controller: _inspectionNotesCtrl,
                              decoration: const InputDecoration(
                                labelText: 'ইন্সপেকশন রিপোর্ট ও নোট (ঐচ্ছিক)',
                                hintText: 'পণ্য ফ্রেশ, সাইজ চমৎকার ও প্রেরণের জন্য তৈরি...',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Pass & Reject Action Buttons
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _isProcessing
                                      ? null
                                      : () async {
                                          final actWeight = double.tryParse(_actualWeightCtrl.text.trim()) ?? o.quantity;
                                          setState(() => _isProcessing = true);
                                          final ok = await repo.verifyOrderQuality(
                                            orderId: o.id,
                                            actualWeight: actWeight,
                                            qualityGrade: _selectedGrade,
                                            verifiedBy: o.inspectorName.isNotEmpty ? o.inspectorName : 'পরীক্ষক',
                                            verificationNotes: _inspectionNotesCtrl.text.trim().isNotEmpty
                                                ? _inspectionNotesCtrl.text.trim()
                                                : 'পণ্য ফ্রেশ ও মানসম্মত (সব চেকলিস্ট উত্তীর্ণ)',
                                          );
                                          setState(() => _isProcessing = false);
                                          if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(ok
                                                    ? '✅ মান যাচাই সফলভাবে সম্পন্ন হয়েছে! ধাপ ৩ (পরিবহন) আনলক হয়েছে।'
                                                    : '❌ যাচাই সাবমিট করতে সমস্যা হয়েছে।'),
                                                backgroundColor: ok ? const Color(0xFF166534) : Colors.red,
                                              ),
                                            );
                                        },
                                  icon: const Icon(Icons.check_circle_outline, size: 18),
                                  label: const Text('চেক কমপ্লিট — মান যাচাই সম্পন্ন (পাস)'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF166534),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                OutlinedButton.icon(
                                  onPressed: _isProcessing ? null : () => _showRejectDialog(context, repo, o),
                                  icon: const Icon(Icons.cancel_outlined, size: 18),
                                  label: const Text('পণ্য বাতিল ও রিফান্ড'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFFDC2626),
                                    side: const BorderSide(color: Color(0xFFDC2626)),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      )),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxItem(String label, bool value, Function(bool?) onChanged) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: value,
            activeColor: const Color(0xFF166534),
            onChanged: onChanged,
          ),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF334155))),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, AdminRepository repo, AdminOrderRecord o) {
    _rejectionReasonCtrl.text = 'কালেকশন হাবে পরীক্ষায় পণ্যের মান মানসম্মত পাওয়া যায়নি।';
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('পণ্য বাতিল ও রিফান্ড প্রক্রিয়া', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'পণ্য মানসম্মত না হলে বাতিল করা হলে ক্রেতার ২০% ডিপোজিট টাকা ফেরত (রিফান্ড) প্রক্রিয়ায় চলে যাবে।',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _rejectionReasonCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'বাতিল করার কারণ লিখুন *',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ফিরে যান'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isProcessing = true);
              final ok = await repo.rejectOrderQuality(
                orderId: o.id,
                rejectionReason: _rejectionReasonCtrl.text.trim(),
              );
              setState(() => _isProcessing = false);
              messenger.showSnackBar(
                SnackBar(
                  content: Text(ok ? 'পণ্য বাতিল ও রিফান্ড প্রসেস শুরু হয়েছে।' : 'সমস্যা হয়েছে।'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
            child: const Text('নিশ্চিত বাতিল করুন'),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // STEP 3 CARD: TRANSPORT & DRIVER DISPATCH
  // -------------------------------------------------------------
  Widget _buildStep3Card(AdminRepository repo, AdminOrderRecord o) {
    final isLocked = !_isStep2Done;
    final isInTransit = _isStep3Done;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLocked
              ? const Color(0xFFE2E8F0)
              : (isInTransit ? const Color(0xFFBBF7D0) : const Color(0xFFFED7AA)),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: isLocked
                  ? const Color(0xFFF8FAFC)
                  : (isInTransit ? const Color(0xFFF0FDF4) : const Color(0xFFFFF7ED)),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isLocked
                        ? const Color(0xFF94A3B8)
                        : (isInTransit ? const Color(0xFF166534) : const Color(0xFFEA580C)),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    isInTransit ? '✓' : '৩',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'ধাপ ৩: পরিবহন ব্যবস্থাপনা ও ড্রাইভার বরাদ্দ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const Spacer(),
                if (isLocked)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('লকড 🔒', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isInTransit ? const Color(0xFFDCFCE7) : const Color(0xFFFFEDD5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isInTransit ? 'পথে চলমান 🚚' : 'ড্রাইভার নির্ধারণ বাকি',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isInTransit ? const Color(0xFF166534) : const Color(0xFFC2410C),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(20),
            child: isLocked
                ? _buildLockedPlaceholder('ধাপ ২ (গুণমান পরীক্ষা) সফল হলে ড্রাইভার ও পরিবহন বরাদ্দ উন্মুক্ত হবে।')
                : (isInTransit
                    ? Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.local_shipping, color: Color(0xFF166534), size: 30),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ট্রাক গন্তব্যের উদ্দেশ্যে রওনা হয়েছে (${o.transportStatusText})',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF166534),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'ড্রাইভার: ${o.driverName} | ফোন: ${o.driverPhone} | গাড়ি নং: ${o.vehicleNumber}',
                                    style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
                                  ),
                                  if (o.deliveryLocation.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        'গন্তব্য: ${o.deliveryLocation}',
                                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _driverNameCtrl.text = o.driverName;
                                  _driverPhoneCtrl.text = o.driverPhone;
                                  _vehicleNumCtrl.text = o.vehicleNumber;
                                });
                              },
                              icon: const Icon(Icons.edit, size: 14),
                              label: const Text('তথ্য আপডেট'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF166534),
                                side: const BorderSide(color: Color(0xFF166534)),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7ED),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFFED7AA)),
                            ),
                            child: const Text(
                              'পণ্য কালেকশন হাবে রেডি রয়েছে। পণ্য ক্রেতার গন্তব্যে পরিবহনের জন্য গাড়ির নম্বর ও ড্রাইভারের বিবরণ দিন:',
                              style: TextStyle(fontSize: 13, color: Color(0xFF9A3412)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _driverNameCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'ড্রাইভারের নাম *',
                                    hintText: 'যেমন: মো: করিম মিয়া',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.person),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: TextFormField(
                                  controller: _driverPhoneCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'ড্রাইভারের মোবাইল নম্বর *',
                                    hintText: '০১৭... / ০১৮...',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.phone),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _vehicleNumCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'গাড়ির নম্বর *',
                                    hintText: 'যেমন: ঢাকা মেট্রো ড-১১-২২৩৩',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.drive_eta),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: TextFormField(
                                  controller: _transportAgencyCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'ট্রান্সপোর্ট এজেন্সি (ঐচ্ছিক)',
                                    hintText: 'যেমন: সুন্দরবন কুরিয়ার / ট্রাকল্যাগবে',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.business),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _isProcessing
                                ? null
                                : () async {
                                    final dName = _driverNameCtrl.text.trim();
                                    final dPhone = _driverPhoneCtrl.text.trim();
                                    final vNum = _vehicleNumCtrl.text.trim();

                                    if (dName.isEmpty || dPhone.isEmpty || vNum.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('অনুগ্রহ করে ড্রাইভারের নাম, ফোন ও গাড়ির নম্বর দিন।')),
                                      );
                                      return;
                                    }

                                    setState(() => _isProcessing = true);
                                    final ok = await repo.updateOrderTransport(
                                      orderId: o.id,
                                      driverName: dName,
                                      driverPhone: dPhone,
                                      vehicleNumber: vNum,
                                      transportStatus: 'in_transit',
                                      pickupLocation: o.farmerLocation,
                                      collectionCenter: '${o.farmerLocation} হাব',
                                    );
                                    setState(() => _isProcessing = false);
                                    if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(ok
                                              ? '✅ ট্রাক গন্তব্যে রওনা হয়েছে! অ্যাপসে রিয়েল-টাইম আপডেট পাঠানো হয়েছে।'
                                              : '❌ পরিবহন আপডেট করতে সমস্যা হয়েছে।'),
                                          backgroundColor: ok ? const Color(0xFF166534) : Colors.red,
                                        ),
                                      );
                                  },
                            icon: const Icon(Icons.local_shipping, size: 18),
                            label: const Text('ড্রাইভার বরাদ্দ করুন ও রওনা দিন (In Transit)'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF166534),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      )),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // STEP 4 CARD: DELIVERY & FARMER PAYOUT
  // -------------------------------------------------------------
  Widget _buildStep4Card(AdminRepository repo, AdminOrderRecord o) {
    final isLocked = !_isStep3Done;
    final isDelivered = _isStep4Delivered;
    final isPayoutPaid = _isStep4PayoutDone;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLocked
              ? const Color(0xFFE2E8F0)
              : (isPayoutPaid ? const Color(0xFFBBF7D0) : const Color(0xFFDDD6FE)),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: isLocked
                  ? const Color(0xFFF8FAFC)
                  : (isPayoutPaid ? const Color(0xFFF0FDF4) : const Color(0xFFFAF5FF)),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isLocked
                        ? const Color(0xFF94A3B8)
                        : (isPayoutPaid ? const Color(0xFF166534) : const Color(0xFF7C3AED)),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    isPayoutPaid ? '✓' : '৪',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'ধাপ ৪: ডেলিভারি সম্পন্ন ও কৃষকের নিট পেআউট (৯৫%) প্রদান',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const Spacer(),
                if (isLocked)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('লকড 🔒', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPayoutPaid ? const Color(0xFFDCFCE7) : const Color(0xFFEDE9FE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isPayoutPaid ? 'পেআউট সম্পন্ন ✅' : (isDelivered ? 'পেআউট বাকি 💸' : 'ডেলিভারি বাকি'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isPayoutPaid ? const Color(0xFF166534) : const Color(0xFF6D28D9),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(20),
            child: isLocked
                ? _buildLockedPlaceholder('ধাপ ৩ (পরিবহন রওনা হওয়া) সম্পন্ন হলে ডেলিভারি ও পেআউট অপশন উন্মুক্ত হবে।')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sub-stage 4A: Delivery Confirmation
                      if (!isDelivered) ...[
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F9FF),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFBAE6FD)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.inventory, color: Color(0xFF0284C7), size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'ড্রাইভার ${o.driverName} পণ্য নিয়ে ক্রেতার ঠিকানায় (${o.deliveryLocation}) পৌঁছে বাকি মূল্য রিসিভ করলে "ডেলিভারি সম্পন্ন" ক্লিক করুন।',
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF0369A1)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton.icon(
                          onPressed: _isProcessing
                              ? null
                              : () async {
                                  setState(() => _isProcessing = true);
                                  final ok = await repo.updateOrderStatus(
                                    orderId: o.id,
                                    status: 'delivered',
                                  );
                                  setState(() => _isProcessing = false);
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(ok
                                            ? '✅ ডেলিভারি সফলভাবে সম্পন্ন হয়েছে! এখন কৃষককে পেআউট করুন।'
                                            : '❌ ডেলিভারি স্ট্যাটাস আপডেটে সমস্যা হয়েছে।'),
                                        backgroundColor: ok ? const Color(0xFF166534) : Colors.red,
                                      ),
                                    );
                                },
                          icon: const Icon(Icons.check_circle, size: 18),
                          label: const Text('পণ্য ক্রেতার কাছে পৌঁছেছে (ডেলিভারি সম্পন্ন)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0284C7),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFBBF7D0)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle, color: Color(0xFF166534), size: 24),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'পণ্য ক্রেতার কাছে সফলভাবে ডেলিভারি হয়েছে এবং সম্পূর্ণ টাকা কৃষিবাজারের একাউন্টে চলে এসেছে।',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Sub-stage 4B: Farmer Payout Disbursed
                        if (isPayoutPaid)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFBBF7D0)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.price_check, color: Color(0xFF166534), size: 30),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'কৃষক ${o.farmerName} এর প্রাপ্য নিট ৳ ${(o.farmerPayoutAmount > 0 ? o.farmerPayoutAmount : (o.totalAmount * 0.95)).toStringAsFixed(2)} পেআউট সফলভাবে পরিশোধিত হয়েছে!',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF166534),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'প্ল্যাটফর্ম ফি ৫%: ৳ ${(o.totalAmount * 0.05).toStringAsFixed(2)} | কৃষকের একাউন্ট স্ট্যাটাস: পরিশোধিত',
                                        style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFAF5FF),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFDDD6FE)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'কৃষকের প্রাপ্য অর্থ হিসাব:',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF6D28D9)),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'মোট বিক্রয় মূল্য: ৳ ${o.totalAmount.toStringAsFixed(2)}  —  ৫% কৃষিবাজার প্ল্যাটফর্ম ফি: ৳ ${(o.totalAmount * 0.05).toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF4C1D95)),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'কৃষক পাবেন নিট (৯৫%): ৳ ${(o.farmerPayoutAmount > 0 ? o.farmerPayoutAmount : (o.totalAmount * 0.95)).toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _payoutTrxCtrl,
                                      decoration: const InputDecoration(
                                        labelText: 'ব্যাংক / বিকাশ লেনদেন ট্রানজেকশন আইডি',
                                        hintText: 'যেমন: BKASH_93847529',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _payoutNotesCtrl,
                                      decoration: const InputDecoration(
                                        labelText: 'পেআউট নোট (ঐচ্ছিক)',
                                        hintText: 'কৃষকের পার্সোনাল নাম্বারে পরিশোধ',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _isProcessing
                                    ? null
                                    : () async {
                                        setState(() => _isProcessing = true);
                                        final ok = await repo.confirmFarmerPayout(
                                          orderId: o.id,
                                          transactionId: _payoutTrxCtrl.text.trim(),
                                          notes: _payoutNotesCtrl.text.trim().isNotEmpty
                                              ? _payoutNotesCtrl.text.trim()
                                              : 'কৃষকের বিকাশ/ব্যাংক অ্যাকাউন্টে টাকা পরিশোধ করা হয়েছে',
                                        );
                                        setState(() => _isProcessing = false);
                                        if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(ok
                                                  ? '✅ কৃষকের একাউন্টে পেআউট কনফার্ম করা হয়েছে! সমগ্র অর্ডার লাইফসাইকেল সম্পন্ন।'
                                                  : '❌ পেআউট কনফার্ম করতে সমস্যা হয়েছে।'),
                                              backgroundColor: ok ? const Color(0xFF166534) : Colors.red,
                                            ),
                                          );
                                      },
                                icon: const Icon(Icons.payments, size: 18),
                                label: Text('কৃষকের একাউন্টে পেআউট পাঠান (৳ ${(o.farmerPayoutAmount > 0 ? o.farmerPayoutAmount : (o.totalAmount * 0.95)).toStringAsFixed(0)})'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF166534),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedPlaceholder(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_clock, color: Color(0xFF94A3B8), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          ),
        ],
      ),
    );
  }
}
