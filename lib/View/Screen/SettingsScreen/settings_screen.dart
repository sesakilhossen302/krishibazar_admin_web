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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminRepository>().fetchPaymentSettingsFromBackend();
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
                    'ক্রেতার ২০% সিকিউরিটি ডিপোজিট সংগ্রহের জন্য বিকাশ, নগদ ও রকেট একাউন্ট নম্বর পরিচালনা ও অন/অফ নিয়ন্ত্রণ',
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: repo.isLoadingSettings
                    ? null
                    : () => repo.fetchPaymentSettingsFromBackend(),
                icon: repo.isLoadingSettings
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.refresh, size: 18),
                label: const Text('রিফ্রেশ'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF166534),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

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

          if (repo.isLoadingSettings && settings.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: CircularProgressIndicator(),
              ),
            )
          else ...[
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
                    mainAxisExtent: 440,
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
          color: isActive ? themeColor.withValues(alpha: 0.4) : const Color(0xFFE2E8F0),
          width: isActive ? 2 : 1,
        ),
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
          // Header: Brand & On/Off Switch
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: themeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(defaultIcon, style: const TextStyle(fontSize: 22)),
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isActive ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          isActive ? 'সক্রিয় (Active) ✅' : 'নিষ্ক্রিয় (Off) ⏸️',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isActive ? const Color(0xFF166534) : const Color(0xFF64748B),
                          ),
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
                  await repo.togglePaymentMethod(item.id, val);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${item.name} এখন ${val ? "সক্রিয় (Active)" : "নিষ্ক্রিয় (Off)"} করা হয়েছে।'),
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
          Text(
            '${item.name} অ্যাকাউন্ট নম্বর *',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
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

                      setState(() => _isSaving[item.id] = true);
                      final updated = item.copyWith(
                        accountNumber: number,
                        accountType: _typeValues[item.id] ?? item.accountType,
                        isActive: _activeValues[item.id] ?? item.isActive,
                        instructions: instrCtrl.text.trim(),
                      );
                      final ok = await repo.savePaymentSetting(updated);
                      setState(() => _isSaving[item.id] = false);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(ok
                                ? '✅ ${item.name} নম্বর সফলভাবে সংরক্ষণ ও আপডেট করা হয়েছে!'
                                : '❌ সেভ করতে সমস্যা হয়েছে।'),
                            backgroundColor: ok ? const Color(0xFF166534) : Colors.red,
                          ),
                        );
                      }
                    },
              icon: isSaving
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check_circle_outline, size: 18),
              label: const Text('সংরক্ষণ ও নিশ্চিত করুন'),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
