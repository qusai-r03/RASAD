import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class CitizenBottomBar extends StatelessWidget {
  final VoidCallback onHome;
  final int selectedIndex;
  final VoidCallback onReports;
  final VoidCallback onMap;
  final VoidCallback onAdd;
  final VoidCallback onProfile;

  const CitizenBottomBar({
    super.key,
    required this.onHome,
    required this.onReports,
    required this.onMap,
    required this.onAdd,
    required this.onProfile,
    this.selectedIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 98,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              height: 68,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6),
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
                  textDirection: TextDirection.ltr,
                  children: [
                    _navItem(
                      Icons.grid_view_outlined,
                      'المزيد',
                      onProfile,
                      selected: selectedIndex == 3,
                    ),
                    _navItem(
                      Icons.assignment_outlined,
                      'شكاواي',
                      onReports,
                      selected: selectedIndex == 2,
                    ),
                    const SizedBox(width: 76),
                    _navItem(
                      Icons.map_outlined,
                      'الخريطة',
                      onMap,
                      selected: selectedIndex == 1,
                    ),
                    _navItem(
                      Icons.home_rounded,
                      'الرئيسية',
                      onHome,
                      selected: selectedIndex == 0,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: onAdd,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, Color(0xFF071B33)],
                      ),
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x4D0F4A7A),
                          blurRadius: 14,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 34),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool selected = false,
  }) {
    final color = selected ? AppColors.primary : AppColors.muted;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
          decoration: selected
              ? BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(18),
                )
              : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 2),
              Text(
                label,
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
