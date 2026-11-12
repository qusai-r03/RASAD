import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../app/router.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user_role.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('هذه الميزة ستتوفر قريباً')));
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await AuthService().signOut();
      roleService.completeSessionRestore(null);
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر تسجيل الخروج. حاول مجدداً.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = roleService.getCurrentUser();
    final authUser = FirebaseAuth.instance.currentUser;

    final role = currentUser?.role;
    final uid = authUser?.uid;

    if (uid == null || currentUser == null || currentUser.id != uid) {
      return const Scaffold(body: Center(child: Text('يرجى تسجيل الدخول')));
    }

    final collection = role == UserRole.employee ? 'employees' : 'citizens';

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text(context.tr('profile'))),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance
            .collection(collection)
            .doc(uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('تعذر تحميل بيانات الملف الشخصي'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('لم يتم العثور على بيانات الحساب'));
          }

          final data = snapshot.data!.data() ?? {};

          final nationalId = data['nationalId'] as String? ?? 'غير متوفر';

          final firstName = data['firstName'] as String? ?? '';

          final lastName = data['lastName'] as String? ?? '';

          final name = '$firstName $lastName'.trim();

          final municipalityId = data['municipalityId'] as String?;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 22,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 38,
                      backgroundColor: Color(0xFFBFDCE8),
                      child: Icon(
                        Icons.person,
                        size: 46,
                        color: Color(0xFF1E4D5C),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      name.isEmpty ? 'مستخدم رصد' : name,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      role == UserRole.employee ? 'موظف بلدية' : 'مواطن',
                      style: const TextStyle(color: AppColors.muted),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'الرقم الوطني: $nationalId',
                      style: const TextStyle(color: AppColors.muted),
                    ),
                    if (role == UserRole.employee && municipalityId != null)
                      Text(
                        'البلدية: $municipalityId',
                        style: const TextStyle(color: AppColors.muted),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: AppDecor.card(radius: 16),
                child: Column(
                  children: [
                    _profileItem(
                      context,
                      Icons.person_outline,
                      'تعديل البيانات الشخصية',
                    ),
                    const Divider(height: 1),
                    _profileItem(
                      context,
                      Icons.lock_outline,
                      'تغيير كلمة المرور',
                    ),
                    const Divider(height: 1),
                    _profileItem(
                      context,
                      Icons.notifications_none,
                      'الإشعارات',
                    ),
                    const Divider(height: 1),
                    _profileItem(context, Icons.help_outline, 'المساعدة'),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.newFg,
                  backgroundColor: AppColors.newBg.withValues(alpha: 0.4),
                  side: const BorderSide(color: AppColors.newFg),
                ),
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout),
                label: const Text('تسجيل الخروج'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _profileItem(BuildContext context, IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: AppColors.muted),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_left, color: AppColors.muted),
      onTap: () => _comingSoon(context),
    );
  }
}
