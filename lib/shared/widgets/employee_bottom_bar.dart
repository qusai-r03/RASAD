import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class EmployeeBottomBar extends StatelessWidget {
  final int selectedIndex;
  final VoidCallback onHome;
  final VoidCallback onReports;
  final VoidCallback onMap;
  final VoidCallback onProfile;

  const EmployeeBottomBar({
    super.key,
    required this.selectedIndex,
    required this.onHome,
    required this.onReports,
    required this.onMap,
    required this.onProfile,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 78,
        margin: const EdgeInsets.fromLTRB(12, 4, 12, 12),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 18,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            _item(Icons.home_rounded, 'الرئيسية', 0, onHome),
            _item(Icons.assignment_outlined, 'البلاغات', 1, onReports),
            _item(Icons.map_outlined, 'الخريطة', 2, onMap),
            _item(Icons.person_outline, 'الملف الشخصي', 3, onProfile),
          ],
        ),
      ),
    );
  }

  Widget _item(IconData icon, String label, int index, VoidCallback onTap) {
    final selected = selectedIndex == index;
    final color = selected ? AppColors.primary : AppColors.muted;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
          decoration: selected
              ? BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(18),
                )
              : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
