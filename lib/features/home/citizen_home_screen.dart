import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/mock/mock_data.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_image.dart';
import '../../shared/widgets/art.dart';
import '../../shared/widgets/rasd_logo.dart';
import '../../shared/widgets/widgets.dart';
import '../auth/current_user_provider.dart';
import '../notifications/notifications_screen.dart';

/// رئيسية المواطن (حسب التصميم). البيانات وهمية لحين ربط شاشات الشكاوى والخريطة.
class CitizenHomeScreen extends ConsumerWidget {
  const CitizenHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final latest =
        mockComplaints.first.copyWith(status: ComplaintStatus.inProgress);

    return Scaffold(
      body: SafeArea(
        child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            children: [
              _Header(firstName: user?.firstName ?? ''),
              const SizedBox(height: 14),
              _HeroCard(onTap: () => context.push('/new-complaint')),
              const SizedBox(height: 12),
              SectionCard(
                icon: Icons.bar_chart_rounded,
                title: context.tr('mySummary'),
                child: Column(children: [
                  Row(children: [
                    StatCard(
                      compact: true,
                      value: citizenSummary.waiting,
                      label: context.tr('statusWaiting'),
                      icon: Icons.error,
                      bg: AppColors.newBg,
                      fg: AppColors.newFg,
                      onTap: () => context.go('/reports?status=new'),
                    ),
                    const SizedBox(width: 10),
                    StatCard(
                      compact: true,
                      value: citizenSummary.progress,
                      label: context.tr('statusProgress'),
                      icon: Icons.schedule,
                      bg: AppColors.progressBg,
                      fg: AppColors.progressFg,
                      onTap: () => context.go('/reports?status=progress'),
                    ),
                    const SizedBox(width: 10),
                    StatCard(
                      compact: true,
                      value: citizenSummary.done,
                      label: context.tr('statusDone'),
                      icon: Icons.check_circle,
                      bg: AppColors.doneBg,
                      fg: AppColors.doneFg,
                      onTap: () => context.go('/reports?status=done'),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  LinkRow(context.tr('viewAllMine'),
                      onTap: () => context.go('/reports')),
                ]),
              ),
              SectionCard(
                icon: Icons.access_time_rounded,
                title: context.tr('latestUpdate'),
                child: Column(children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                          color: AppColors.primarySoft, shape: BoxShape.circle),
                      child: const Icon(Icons.edit_road_rounded,
                          color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(latest.title,
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w700)),
                            Text('#${latest.id}',
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.muted)),
                            const SizedBox(height: 6),
                            StatusChip(latest.status, withIcon: true),
                            const SizedBox(height: 6),
                            Text(
                                '${context.tr('lastUpdated')} ${context.tr('twoHoursAgo')}',
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.muted)),
                          ]),
                    ),
                    const SizedBox(width: 10),
                    ComplaintThumb(latest, width: 120, height: 84),
                  ]),
                  const SizedBox(height: 6),
                  LinkRow(context.tr('viewDetails'),
                      onTap: () => context.push('/complaint/${latest.id}')),
                ]),
              ),
              SectionCard(
                icon: Icons.location_on,
                title: context.tr('nearbyAlerts'),
                child: Column(children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                          color: AppColors.primarySoft, shape: BoxShape.circle),
                      child: const Icon(Icons.school_outlined,
                          color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(context.tr('nearUni'),
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Row(children: [
                              Flexible(
                                child: Text(context.tr('potholeHigh'),
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.newFg,
                                        fontWeight: FontWeight.w600)),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.error,
                                  size: 15, color: AppColors.newFg),
                            ]),
                            const SizedBox(height: 4),
                            Text(context.tr('distance300'),
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.muted)),
                          ]),
                    ),
                  ]),
                  const SizedBox(height: 6),
                  LinkRow(context.tr('viewOnMap'),
                      onTap: () => context.go('/map')),
                  const SizedBox(height: 6),
                  Material(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () => context.push('/saved-places'),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.bookmark_border_rounded,
                                  color: AppColors.primary, size: 20),
                              const SizedBox(width: 8),
                              Text(context.tr('manageSaved'),
                                  style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700)),
                            ]),
                      ),
                    ),
                  ),
                ]),
              ),
              _RouteCard(onTap: () => context.push('/route-check')),
            ]),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  final String firstName;
  const _Header({required this.firstName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadCountProvider);
    return Stack(children: [
      Positioned(
        left: 0,
        top: 18,
        width: 190,
        height: 110,
        child: ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Colors.transparent],
          ).createShader(bounds),
          child: const AppImage(
              asset: AppAssets.skyline,
              fit: BoxFit.cover,
              fallback: SkylineArt()),
        ),
      ),
      Column(children: [
        SizedBox(
          height: 52,
          child: Stack(alignment: Alignment.center, children: [
            const RasdLogo(size: 40),
            PositionedDirectional(
              start: 0,
              child: IconButton(
                onPressed: () => context.push('/notifications'),
                icon: Stack(clipBehavior: Clip.none, children: [
                  const Icon(Icons.notifications_none_rounded, size: 28),
                  if (unread > 0)
                    Positioned(
                      top: -1,
                      right: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                            color: AppColors.newFg, shape: BoxShape.circle),
                      ),
                    ),
                ]),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 10),
        Row(children: [
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
                color: Color(0xFFE3EEF3), shape: BoxShape.circle),
            child: const Icon(Icons.person, size: 34, color: Color(0xFF1E4D5C)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${context.tr('hello')} $firstName!',
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w800)),
              Text(context.tr('citizenTagline'),
                  style: const TextStyle(fontSize: 13, color: AppColors.muted)),
            ]),
          ),
        ]),
      ]),
    ]);
  }
}

class _HeroCard extends StatelessWidget {
  final VoidCallback onTap;
  const _HeroCard({required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 128,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
            gradient: const LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [Color(0xFFF2FAF5), Color(0xFFD2EDDB)],
            ),
          ),
          child: Row(children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.tr('heroTitle'),
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Text(context.tr('heroSub'),
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.muted,
                              height: 1.45)),
                    ]),
              ),
            ),
            const SizedBox(
              width: 150,
              height: double.infinity,
              child: AppImage(asset: AppAssets.hero, fallback: HeroArt()),
            ),
          ]),
        ),
      );
}

class _RouteCard extends StatelessWidget {
  final VoidCallback onTap;
  const _RouteCard({required this.onTap});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: AppDecor.card(),
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: const SizedBox(
              width: 130,
              height: 120,
              child: AppImage(asset: AppAssets.road, fallback: RoadArt()),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.alt_route_rounded,
                    color: AppColors.primary, size: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(context.tr('routeTitle'),
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w800)),
                ),
              ]),
              const SizedBox(height: 6),
              Text(context.tr('routeSub'),
                  style: const TextStyle(
                      fontSize: 12.5, color: AppColors.muted, height: 1.4)),
              const SizedBox(height: 10),
              SizedBox(
                height: 44,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
                  onPressed: onTap,
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: Text(context.tr('checkRoute')),
                ),
              ),
            ]),
          ),
        ]),
      );
}
