import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/services/employee_home_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/report_model.dart';

class EmployeeHomeScreen extends StatefulWidget {
  const EmployeeHomeScreen({super.key});

  @override
  State<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> {
  late final Future<EmployeeHomeData> _homeData;

  @override
  void initState() {
    super.initState();

    final uid = FirebaseAuth.instance.currentUser?.uid;
    final appUser = roleService.getCurrentUser();

    if (uid == null || appUser == null || appUser.id != uid) {
      _homeData = Future.error(StateError('Employee session is unavailable.'));
    } else {
      _homeData = EmployeeHomeService().load(uid);
    }
  }

  void _comingSoon() {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('الخريطة ستتوفر قريباً')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<EmployeeHomeData>(
          future: _homeData,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'تعذر تحميل بيانات الموظف.\n'
                    'تأكد من وجود حساب الموظف وبلديته في Firestore.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final data = snapshot.data!;

            return Directionality(
              textDirection: TextDirection.rtl,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 22,
                        backgroundColor: Color(0xFFE3EEF3),
                        child: Icon(Icons.person, color: Color(0xFF1E4D5C)),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => context.go('/profile'),
                        icon: const Icon(Icons.account_circle_outlined),
                        tooltip: 'الملف الشخصي',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'مرحباً بك في رصد!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'لوحة موظف البلدية: ${data.municipalityId}',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          value: data.pendingCount,
                          label: 'بلاغات جديدة',
                          icon: Icons.description_outlined,
                          background: AppColors.newBg,
                          foreground: AppColors.newFg,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _statCard(
                          value: data.inProgressCount,
                          label: 'قيد المعالجة',
                          icon: Icons.schedule,
                          background: AppColors.progressBg,
                          foreground: AppColors.progressFg,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _statCard(
                          value: data.resolvedCount,
                          label: 'مكتملة',
                          icon: Icons.check_circle_outline,
                          background: AppColors.doneBg,
                          foreground: AppColors.doneFg,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _comingSoon,
                    icon: const Icon(Icons.map_outlined),
                    label: const Text('عرض الخريطة'),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Text(
                        'أحدث البلاغات',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => context.go('/reports'),
                        child: const Text('عرض الكل'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (data.latestReports.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
                          'لا توجد بلاغات لهذه البلدية حالياً',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    for (final report in data.latestReports)
                      _reportCard(report),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _statCard({
    required int value,
    required String label,
    required IconData icon,
    required Color background,
    required Color foreground,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: foreground, size: 26),
          const SizedBox(height: 8),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w800,
              color: foreground,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _reportCard(ReportModel report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(
          Icons.description_outlined,
          color: AppColors.primary,
        ),
        title: Text(
          report.category,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          report.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          report.status,
          style: const TextStyle(color: AppColors.muted, fontSize: 12),
        ),
        onTap: () => context.go('/reports'),
      ),
    );
  }
}
