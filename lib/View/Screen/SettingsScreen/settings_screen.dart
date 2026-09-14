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
                    'ক্রেতার ২০% সিকিউরিটি ডিপোজিট সংগ্রহের জন্য বিকাশ, নগদ ও রকেট একাউন্ট নম্বর পরিচালনা ও অন/অফ নিয়ন্ত্রণ',
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
