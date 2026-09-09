import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Utils/AppColors/app_colors.dart';
import '../../../../global/Model/admin_models.dart';
import '../../../../global/controller/admin_repository.dart';

class FarmerVerificationScreen extends StatelessWidget {
  const FarmerVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AdminRepository>();
    final farmers = repo.farmers;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'কৃষক যাচাই ও অনুমোদন (${farmers.length} জন)',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              ElevatedButton.icon(
                onPressed: repo.isLoadingUsers ? null : () => repo.fetchUsersFromBackend(),
                icon: repo.isLoadingUsers
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('রিফ্রেশ করুন'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 900;
              final list = farmers.map((farmer) {
                final isVerified = farmer.status == VerificationStatus.verified;
                return InkWell(
                  onTap: () => repo.openUserDetailFromFarmer(farmer),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: const Color(0xFFDCFCE7),
                              backgroundImage: (farmer.photoUrl != null && farmer.photoUrl!.isNotEmpty)
                                  ? NetworkImage(farmer.photoUrl!)
                                  : null,
                              child: (farmer.photoUrl == null || farmer.photoUrl!.isEmpty)
                                  ? const Icon(Icons.person, color: Color(0xFF166534), size: 20)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    farmer.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'ফোন: ${farmer.phone} • NID: ${farmer.nid}',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    farmer.location + (farmer.farmerType.isNotEmpty ? ' • ${farmer.farmerType}' : ''),
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isVerified ? const Color(0xFFDCFCE7) : const Color(0xFFFFEDD5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isVerified ? 'যাচাইকৃত (Verified ✅)' : 'অপেক্ষমাণ (Pending)',
                                style: TextStyle(
                                  color: isVerified ? const Color(0xFF166534) : const Color(0xFFEA580C),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (!isVerified) ...[
                              ElevatedButton.icon(
                                onPressed: () => repo.approveFarmer(farmer.id),
                                icon: const Icon(Icons.check, size: 16),
                                label: const Text('অনুমোদন করুন ✅'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF166534),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            OutlinedButton(
                              onPressed: () => repo.rejectFarmer(farmer.id),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('বাতিল'),
                            ),
                          ],
                        ),
                      ],
                    ),
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
