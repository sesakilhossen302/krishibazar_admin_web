import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../global/Model/admin_models.dart';
import '../../../../global/controller/admin_repository.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Method editing state maps
  final Map<String, TextEditingController> _numberControllers = {};
  final Map<String, TextEditingController> _instrControllers = {};
  final Map<String, String> _typeValues = {};
  final Map<String, bool> _activeValues = {};
  final Map<String, bool> _isSaving = {};

  int _activeSubTabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminRepository>().fetchPaymentSettingsFromBackend();
      context.read<AdminRepository>().fetchDeliveryChartsFromBackend();
    });
  }

  @override
  void dispose() {
    for (var c in _numberControllers.values) {
      c.dispose();
    }
    for (var c in _instrControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _syncControllers(List<PaymentSettingModel> settings) {
    for (var s in settings) {
      if (!_numberControllers.containsKey(s.id)) {
        _numberControllers[s.id] = TextEditingController(text: s.accountNumber);
        _instrControllers[s.id] = TextEditingController(text: s.instructions);
        _typeValues[s.id] = s.accountType;
        _activeValues[s.id] = s.isActive;
        _isSaving[s.id] = false;
      }
    }
  }

  void _showAddPaymentMethodDialog(BuildContext context, AdminRepository repo) {
    final nameCtrl = TextEditingController(text: 'বিকাশ');
    final numCtrl = TextEditingController();
    final instrCtrl = TextEditingController(text: 'টাকা পাঠিয়ে ট্রানজেকশন আইডি ও স্ক্রিনশট দিন।');
    String selectedType = 'Personal';
    bool isActive = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.add_card_rounded, color: Color(0xFF166534), size: 24),
              SizedBox(width: 10),
              Text(
                'নতুন পেমেন্ট গেটওয়ে বা নম্বর যোগ করুন',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 480,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'পেমেন্ট মেথডের নাম *',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: nameCtrl.text,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'বিকাশ', child: Text('বিকাশ (bKash)')),
                      DropdownMenuItem(value: 'নগদ', child: Text('নগদ (Nagad)')),
                      DropdownMenuItem(value: 'রকেট', child: Text('রকেট (Rocket)')),
                      DropdownMenuItem(value: 'উপায়', child: Text('উপায় (Upay)')),
                      DropdownMenuItem(value: 'ইসলামী ব্যাংক', child: Text('ইসলামী ব্যাংক বাংলাদেশ')),
                      DropdownMenuItem(value: 'অন্যান্য ব্যাংক', child: Text('অন্যান্য ব্যাংক / সার্ভিস')),
                    ],
                    onChanged: (val) {
                      if (val != null) setDlgState(() => nameCtrl.text = val);
                    },
                  ),
                  const SizedBox(height: 14),

                  const Text(
                    'অ্যাকাউন্ট নম্বর *',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: numCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'যেমন: 01712-345678',
                      prefixIcon: const Icon(Icons.phone_android, size: 18, color: Color(0xFF166534)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 14),

                  const Text(
                    'অ্যাকাউন্ট টাইপ',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Personal', child: Text('পার্সোনাল (Personal)')),
                      DropdownMenuItem(value: 'Merchant', child: Text('মার্চেন্ট (Merchant)')),
                      DropdownMenuItem(value: 'Agent', child: Text('এজেন্ট (Agent)')),
                      DropdownMenuItem(value: 'Bank', child: Text('ব্যাংক একাউন্ট')),
                    ],
                    onChanged: (val) {
                      if (val != null) setDlgState(() => selectedType = val);
                    },
                  ),
                  const SizedBox(height: 14),

                  const Text(
                    'ক্রেতার জন্য নির্দেশিকা',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: instrCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'যেমন: টাকা পাঠিয়ে TrxID ও স্ক্রিনশট দিন...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'সরাসরি অন (সক্রিয়) রাখুন:',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
                      Switch(
                        value: isActive,
                        activeThumbColor: const Color(0xFF166534),
                        onChanged: (val) => setDlgState(() => isActive = val),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('বাতিল', style: TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton(
              onPressed: () async {
                final numStr = numCtrl.text.trim();
                if (numStr.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('অনুগ্রহ করে একটি অ্যাকাউন্ট নম্বর দিন।')),
                  );
                  return;
                }

                String id = nameCtrl.text.toLowerCase();
                if (id.contains('বিকাশ')) {
                  id = 'bkash';
                } else if (id.contains('নগদ')) {
                  id = 'nagad';
                } else if (id.contains('রকেট')) {
                  id = 'rocket';
                } else if (id.contains('উপায়')) {
                  id = 'upay';
                } else {
                  id = 'method_${DateTime.now().millisecondsSinceEpoch}';
                }

                final newSetting = PaymentSettingModel(
                  id: id,
                  name: nameCtrl.text,
                  accountNumber: numStr,
                  accountType: selectedType,
                  isActive: isActive,
                  instructions: instrCtrl.text.trim(),
                );

                Navigator.pop(ctx);
                final ok = await repo.savePaymentSetting(newSetting);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ok ? '✅ ${newSetting.name} সফলভাবে সংরক্ষণ ও সক্রিয় করা হয়েছে!' : '❌ সেভ করতে সমস্যা হয়েছে।'),
                      backgroundColor: ok ? const Color(0xFF166534) : Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF166534),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('সংরক্ষণ ও অন করুন', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AdminRepository>();
    final settings = repo.paymentSettings;
    _syncControllers(settings);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'সিস্টেম ও পেমেন্ট গেটওয়ে সেটিংস',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'ডেলিভারি চার্জ ও সার্ভিস ফি সংগ্রহের জন্য বিকাশ, নগদ ও রকেট একাউন্ট নম্বর পরিচালনা ও অন/অফ নিয়ন্ত্রণ',
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showAddPaymentMethodDialog(context, repo),
                    icon: const Icon(Icons.add, size: 18, color: Colors.white),
                    label: const Text(
                      'নতুন নম্বর / মেথড যুক্ত করুন',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: repo.isLoadingSettings
                        ? null
                        : () => repo.fetchPaymentSettingsFromBackend(),
                    icon: repo.isLoadingSettings
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF166534)),
                          )
                        : const Icon(Icons.refresh, size: 18, color: Color(0xFF166534)),
                    label: const Text('রিফ্রেশ', style: TextStyle(color: Color(0xFF166534))),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF166534)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Sub-Tab Switcher
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSubTabButton(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'পেমেন্ট গেটওয়ে ও নম্বর',
                  index: 0,
                ),
                const SizedBox(width: 6),
                _buildSubTabButton(
                  icon: Icons.local_shipping_outlined,
                  label: 'ডেলিভারি চার্জ চার্ট (Delivery Chart)',
                  index: 1,
                  count: repo.deliveryCharts.length,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          if (_activeSubTabIndex == 1)
            _buildDeliveryChartSection(context, repo)
          else ...[
          // Security Alert Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: Row(
              children: const [
                Icon(Icons.shield_outlined, color: Color(0xFF166534), size: 28),
                SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'যে পেমেন্ট মেথডগুলো আপনি "অন (সক্রিয়)" রাখবেন, ক্রেতারা পণ্য কেনার পর ডিপোজিট দেওয়ার সময় শুধুমাত্র সেই নম্বরগুলো দেখতে পাবেন এবং সেখান থেকে সহজেই নম্বর কপি করে স্ক্রিনশট ও TrxID আপলোড করতে পারবেন।',
                    style: TextStyle(fontSize: 13, color: Color(0xFF14532D), height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Payment Cards Grid (bKash, Nagad, Rocket)
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 1024;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isWide ? 3 : (constraints.maxWidth >= 680 ? 2 : 1),
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  mainAxisExtent: 460,
                ),
                itemCount: settings.length,
                itemBuilder: (context, index) {
                  final item = settings[index];
                  return _buildPaymentCard(context, item, repo);
                },
              );
            },
          ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubTabButton({
    required IconData icon,
    required String label,
    required int index,
    int? count,
  }) {
    final isSelected = _activeSubTabIndex == index;
    return InkWell(
      onTap: () {
        setState(() => _activeSubTabIndex = index);
        if (index == 1) {
          context.read<AdminRepository>().fetchDeliveryChartsFromBackend();
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? const Color(0xFF166534) : const Color(0xFF64748B),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFDCFCE7) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? const Color(0xFF166534) : const Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryChartSection(BuildContext context, AdminRepository repo) {
    final charts = repo.deliveryCharts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Delivery Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Row(
            children: const [
              Icon(Icons.info_outline, color: Color(0xFF1D4ED8), size: 28),
              SizedBox(width: 14),
              Expanded(
                child: Text(
                  '💡 অটোমেটিক ডেলিভারি চার্জ নির্ধারণ:\nএখানে পণ্যের নাম ও পরিমাণের স্ল্যাব (যেমন: ১০ কেজি, ২০ কেজি, ৫০ মণ ইত্যাদি) দিয়ে চার্জ বসিয়ে রাখুন। ক্রেতার বুকিংয়ে এই চার্জ স্বয়ংক্রিয়ভাবে প্রযোজ্য হবে। হাবে পণ্য পরীক্ষার পর ক্রেতা শুধু এই ডেলিভারি চার্জ + ৫% সার্ভিস চার্জ পরিশোধ করবেন।',
                  style: TextStyle(fontSize: 13, color: Color(0xFF1E3A8A), height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Action Toolbar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.table_chart_outlined, color: Color(0xFF166534), size: 22),
                const SizedBox(width: 8),
                Text(
                  'নির্ধারিত ডেলিভারি চার্ট তালিকা (${charts.length}টি স্ল্যাব)',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
              ],
            ),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showAddOrEditDeliveryChartDialog(context, repo),
                  icon: const Icon(Icons.add, size: 18, color: Colors.white),
                  label: const Text(
                    'নতুন চার্ট রুল যোগ করুন',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF166534),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: repo.isLoadingDeliveryCharts
                      ? null
                      : () => repo.fetchDeliveryChartsFromBackend(),
                  icon: repo.isLoadingDeliveryCharts
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF166534)),
                        )
                      : const Icon(Icons.refresh, size: 18, color: Color(0xFF166534)),
                  label: const Text('রিফ্রেশ', style: TextStyle(color: Color(0xFF166534))),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF166534)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Table
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: repo.isLoadingDeliveryCharts
              ? const Padding(
                  padding: EdgeInsets.all(48),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Color(0xFF166534)),
                        SizedBox(height: 12),
                        Text('ডেলিভারি চার্ট ডাটা লোড হচ্ছে...', style: TextStyle(color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                )
              : charts.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child: Text('কোনো ডেলিভারি চার্ট যোগ করা হয়নি। ওপরের বাটন চেপে চার্ট যোগ করুন।'),
                      ),
                    )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                    dataRowMinHeight: 52,
                    dataRowMaxHeight: 56,
                    horizontalMargin: 20,
                    columnSpacing: 24,
                    columns: const [
                      DataColumn(label: Text('পণ্য / শিরোনাম', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('ক্যাটাগরি', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('পরিমাণ রেঞ্জ / স্ল্যাব', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('ইউনিট', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('ডেলিভারি চার্জ', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('চার্জের ধরন', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('অবস্থা', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('অ্যাকশন', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: charts.map((item) {
                      final isMon = item.unit.contains('মণ') || item.unit.contains('mon');
                      final slabText = '${item.minQuantity.toStringAsFixed(0)} - ${item.maxQuantity.toStringAsFixed(0)} ${item.unit}';
                      final chargeText = item.chargeType == 'per_unit'
                          ? '৳${item.deliveryCharge.toStringAsFixed(0)} / ${isMon ? "মণ" : "কেজি"}'
                          : '৳${item.deliveryCharge.toStringAsFixed(0)} (ফিক্সড)';

                      return DataRow(
                        cells: [
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0FDF4),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFFBBF7D0)),
                                  ),
                                  child: Text(
                                    item.productName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(Text(item.category)),
                          DataCell(Text(slabText, style: const TextStyle(fontWeight: FontWeight.w600))),
                          DataCell(Text(item.unit)),
                          DataCell(
                            Text(
                              chargeText,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: item.chargeType == 'per_unit' ? const Color(0xFFFEF3C7) : const Color(0xFFE0F2FE),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item.chargeType == 'per_unit' ? 'প্রতি ইউনিট' : 'ফিক্সড স্ল্যাব',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: item.chargeType == 'per_unit' ? const Color(0xFFB45309) : const Color(0xFF0369A1),
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Switch(
                              value: item.isActive,
                              activeColor: const Color(0xFF166534),
                              onChanged: (val) async {
                                await repo.updateDeliveryChart(item.id, {'is_active': val});
                              },
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF2563EB)),
                                  tooltip: 'এডিট করুন',
                                  onPressed: () => _showAddOrEditDeliveryChartDialog(context, repo, item),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                  tooltip: 'মুছে ফেলুন',
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('ডেলিভারি চার্ট মুছবেন?'),
                                        content: Text('আপনি কি নিশ্চিত যে "${item.productName}" এর ($slabText) চার্ট রুলটি মুছে ফেলতে চান?'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('না')),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                            onPressed: () => Navigator.pop(ctx, true),
                                            child: const Text('মুছে ফেলুন', style: TextStyle(color: Colors.white)),
                                          ),
                                        ],
                                      ),
                                    );
                                     if (confirm == true) {
                                       final ok = await repo.deleteDeliveryChart(item.id);
                                       if (context.mounted) {
                                         ScaffoldMessenger.of(context).showSnackBar(
                                           SnackBar(
                                             content: Text(ok ? '✅ চার্টটি মুছে ফেলা হয়েছে।' : '❌ চার্ট মুছতে সমস্যা হয়েছে।'),
                                             backgroundColor: ok ? const Color(0xFF166534) : Colors.red,
                                           ),
                                         );
                                       }
                                     }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
        ),
      ],
    );
  }

  void _showAddOrEditDeliveryChartDialog(
    BuildContext context,
    AdminRepository repo, [
    DeliveryChartModel? existing,
  ]) {
    final isEdit = existing != null;
    final prodCtrl = TextEditingController(text: existing?.productName ?? 'আলু');
    final catCtrl = TextEditingController(text: existing?.category ?? 'সবজি');
    final minQtyCtrl = TextEditingController(text: existing != null ? existing.minQuantity.toStringAsFixed(0) : '0');
    final maxQtyCtrl = TextEditingController(text: existing != null ? existing.maxQuantity.toStringAsFixed(0) : '50');
    final chargeCtrl = TextEditingController(text: existing != null ? existing.deliveryCharge.toStringAsFixed(0) : '500');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    String selectedUnit = existing?.unit ?? 'মণ (mon)';
    String selectedChargeType = existing?.chargeType ?? 'fixed';
    bool isActive = existing?.isActive ?? true;
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(isEdit ? Icons.edit_note_rounded : Icons.add_chart_rounded, color: const Color(0xFF166534), size: 24),
              const SizedBox(width: 10),
              Text(
                isEdit ? 'ডেলিভারি চার্ট রুল পরিবর্তন করুন' : 'নতুন ডেলিভারি চার্ট রুল যোগ করুন',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('পণ্যের নাম * (যেমন: আলু, পেঁয়াজ, অথবা সকল পণ্য)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: prodCtrl,
                    decoration: InputDecoration(
                      hintText: 'উদা: আলু, পেঁয়াজ, ধান, সকল পণ্য',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('ক্যাটাগরি', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              value: catCtrl.text,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'সবজি', child: Text('সবজি')),
                                DropdownMenuItem(value: 'ফল', child: Text('ফল')),
                                DropdownMenuItem(value: 'শস্য', child: Text('শস্য ও ডাল')),
                                DropdownMenuItem(value: 'সকল ক্যাটাগরি', child: Text('সকল ক্যাটাগরি')),
                              ],
                              onChanged: (val) {
                                if (val != null) setDlgState(() => catCtrl.text = val);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('ইউনিট *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              value: selectedUnit,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'মণ (mon)', child: Text('মণ (mon)')),
                                DropdownMenuItem(value: 'কেজি (kg)', child: Text('কেজি (kg)')),
                                DropdownMenuItem(value: 'টন (ton)', child: Text('টন (ton)')),
                              ],
                              onChanged: (val) {
                                if (val != null) setDlgState(() => selectedUnit = val);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('সর্বনিম্ন পরিমাণ (Min)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: minQtyCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '0',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('সর্বোচ্চ পরিমাণ (Max)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: maxQtyCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '50',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('ডেলিভারি চার্জ (টাকা) *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: chargeCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '500',
                                prefixText: '৳ ',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('চার্জের ধরন', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              value: selectedChargeType,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'fixed', child: Text('ফিক্সড মোট টাকা')),
                                DropdownMenuItem(value: 'per_unit', child: Text('প্রতি একক / মণ')),
                              ],
                              onChanged: (val) {
                                if (val != null) setDlgState(() => selectedChargeType = val);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  const Text('বিবরণ / নোট (ঐচ্ছিক)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: descCtrl,
                    decoration: InputDecoration(
                      hintText: 'উদা: আলু ৫০ মণ হলে ডেলিভারি চার্জ ৫০০ টাকা',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Switch(
                        value: isActive,
                        activeColor: const Color(0xFF166534),
                        onChanged: (val) => setDlgState(() => isActive = val),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isActive ? 'চার্ট সক্রিয় (Active) থাকবে' : 'চার্ট নিষ্ক্রিয় (Inactive)',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('বাতিল', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF166534),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: isSaving
                  ? null
                  : () async {
                      final pName = prodCtrl.text.trim();
                      final minQ = double.tryParse(minQtyCtrl.text.trim()) ?? 0.0;
                      final maxQ = double.tryParse(maxQtyCtrl.text.trim()) ?? 100000.0;
                      final charge = double.tryParse(chargeCtrl.text.trim()) ?? 0.0;

                      if (pName.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('অনুগ্রহ করে পণ্যের নাম দিন।')),
                        );
                        return;
                      }

                      setDlgState(() => isSaving = true);

                      bool success = false;
                      try {
                        if (isEdit) {
                          success = await repo.updateDeliveryChart(existing.id, {
                            'product_name': pName,
                            'category': catCtrl.text.trim(),
                            'min_quantity': minQ,
                            'max_quantity': maxQ,
                            'unit': selectedUnit,
                            'delivery_charge': charge,
                            'charge_type': selectedChargeType,
                            'description': descCtrl.text.trim(),
                            'is_active': isActive,
                          });
                        } else {
                          final newModel = DeliveryChartModel(
                            id: '',
                            productName: pName,
                            category: catCtrl.text.trim(),
                            minQuantity: minQ,
                            maxQuantity: maxQ,
                            unit: selectedUnit,
                            deliveryCharge: charge,
                            chargeType: selectedChargeType,
                            description: descCtrl.text.trim(),
                            isActive: isActive,
                            createdAt: '',
                            updatedAt: '',
                          );
                          success = await repo.createDeliveryChart(newModel);
                        }
                      } catch (e) {
                        debugPrint('Error saving delivery chart: $e');
                        success = false;
                      }

                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                      }

                      if (context.mounted) {
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isEdit ? '✅ ডেলিভারি চার্ট আপডেট হয়েছে।' : '✅ নতুন ডেলিভারি চার্ট সফলভাবে যোগ করা হয়েছে।'),
                              backgroundColor: const Color(0xFF166534),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('❌ চার্ট সেভ হতে সমস্যা হয়েছে। ব্যাকএন্ড সার্ভার সক্রিয় আছে কিনা নিশ্চিত করুন।'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              child: isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(isEdit ? 'সংরক্ষণ করুন' : 'চার্ট যোগ করুন', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context, PaymentSettingModel item, AdminRepository repo) {
    Color themeColor;
    String brandLogoText;
    String defaultIcon = '📱';

    switch (item.id.toLowerCase()) {
      case 'bkash':
        themeColor = const Color(0xFFE2136E);
        brandLogoText = 'বিকাশ (bKash)';
        defaultIcon = '🌸';
        break;
      case 'nagad':
        themeColor = const Color(0xFFF7941D);
        brandLogoText = 'নগদ (Nagad)';
        defaultIcon = '🔥';
        break;
      case 'rocket':
        themeColor = const Color(0xFF8C3494);
        brandLogoText = 'রকেট (Rocket)';
        defaultIcon = '🚀';
        break;
      default:
        themeColor = const Color(0xFF0284C7);
        brandLogoText = item.name;
    }

    final numCtrl = _numberControllers[item.id] ?? TextEditingController(text: item.accountNumber);
    final instrCtrl = _instrControllers[item.id] ?? TextEditingController(text: item.instructions);
    final currentType = _typeValues[item.id] ?? item.accountType;
    final isActive = _activeValues[item.id] ?? item.isActive;
    final isSaving = _isSaving[item.id] ?? false;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? themeColor.withValues(alpha: 0.5) : const Color(0xFFE2E8F0),
          width: isActive ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isActive ? themeColor.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Brand & Switch
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: themeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(defaultIcon, style: const TextStyle(fontSize: 20)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        brandLogoText,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: themeColor,
                        ),
                      ),
                      Text(
                        isActive ? 'অন (সক্রিয়)' : 'অফ (নিষ্ক্রিয়)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isActive ? const Color(0xFF166534) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Switch(
                value: isActive,
                activeThumbColor: themeColor,
                onChanged: (val) async {
                  setState(() {
                    _activeValues[item.id] = val;
                  });
                  // Auto-save currently entered number and instructions when toggling switch
                  final updated = item.copyWith(
                    accountNumber: numCtrl.text.trim().isNotEmpty ? numCtrl.text.trim() : item.accountNumber,
                    accountType: _typeValues[item.id] ?? item.accountType,
                    isActive: val,
                    instructions: instrCtrl.text.trim(),
                  );
                  await repo.savePaymentSetting(updated);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${item.name} এখন ${val ? "সক্রিয় (Active) ও সেভ" : "নিষ্ক্রিয় (Off) ও সেভ"} করা হয়েছে।'),
                        backgroundColor: val ? const Color(0xFF166534) : const Color(0xFF475569),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 16),

          // Account Number Input
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${item.name} একাউন্ট নম্বর দিন *',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
              ),
              if (item.accountNumber.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('এডিট করতে পারেন', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                ),
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: numCtrl,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: 'যেমন: 01712-345678',
              prefixIcon: Icon(Icons.phone_android, size: 18, color: themeColor),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 14),

          // Account Type Selector
          const Text(
            'অ্যাকাউন্ট টাইপ',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: currentType,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.account_balance_outlined, size: 18),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            items: const [
              DropdownMenuItem(value: 'Personal', child: Text('পার্সোনাল (Personal)')),
              DropdownMenuItem(value: 'Merchant', child: Text('মার্চেন্ট (Merchant)')),
              DropdownMenuItem(value: 'Agent', child: Text('এজেন্ট (Agent)')),
              DropdownMenuItem(value: 'Bank', child: Text('ব্যাংক একাউন্ট')),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _typeValues[item.id] = val);
            },
          ),
          const SizedBox(height: 14),

          // Instructions input
          const Text(
            'ক্রেতার জন্য নির্দেশিকা',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: instrCtrl,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'যেমন: টাকা পাঠিয়ে TrxID ও স্ক্রিনশট দিন...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          ),
          const Spacer(),

          // Save / Confirm Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isSaving
                  ? null
                  : () async {
                      final number = numCtrl.text.trim();
                      if (number.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('অনুগ্রহ করে ${item.name} নম্বরটি লিখুন।')),
                        );
                        return;
                      }

                      setState(() {
                        _isSaving[item.id] = true;
                        // Automatically turn ON when clicking Save!
                        _activeValues[item.id] = true;
                      });

                      final updated = item.copyWith(
                        accountNumber: number,
                        accountType: _typeValues[item.id] ?? item.accountType,
                        isActive: true, // Auto ON upon save!
                        instructions: instrCtrl.text.trim(),
                      );
                      final ok = await repo.savePaymentSetting(updated);
                      setState(() => _isSaving[item.id] = false);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(ok
                                ? '✅ ${item.name} নম্বর সফলভাবে সংরক্ষণ ও সক্রিয় (On) করা হয়েছে!'
                                : '❌ সেভ করতে সমস্যা হয়েছে।'),
                            backgroundColor: ok ? const Color(0xFF166534) : Colors.red,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    },
              icon: isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check_circle_outline, size: 18, color: Colors.white),
              label: Text(
                isSaving ? 'সংরক্ষণ হচ্ছে...' : 'সংরক্ষণ ও অন (Active) করুন',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
