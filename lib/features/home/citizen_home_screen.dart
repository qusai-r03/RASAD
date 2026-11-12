import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/services/citizen_home_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/report_model.dart';
import '../../shared/widgets/app_image.dart';
import '../../shared/widgets/art.dart';
import '../../shared/widgets/rasd_logo.dart';
import '../../shared/widgets/widgets.dart';

class CitizenHomeScreen extends StatefulWidget {
  const CitizenHomeScreen({super.key});

  @override
  State<CitizenHomeScreen> createState() => _CitizenHomeScreenState();
}

class _CitizenHomeScreenState extends State<CitizenHomeScreen> {
  late final Future<CitizenHomeData> _homeData;

  @override
  void initState() {
    super.initState();

    final uid = roleService.getCurrentUser()?.id;

    _homeData = uid == null
        ? Future.error(StateError('Citizen not authenticated'))
        : CitizenHomeService().load(uid);
  }

  void _comingSoon() {
    showSoon(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<CitizenHomeData>(
          future: _homeData,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Unable to load reports: ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final data = snapshot.requireData;

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: [
                _buildHeader(),
                const SizedBox(height: 14),
                _buildHeroCard(),
                const SizedBox(height: 12),
                _buildSummary(data),
                _buildLatestReport(data.latestReport),
                _buildNearbyAlerts(),
                _buildRouteCard(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const SizedBox(height: 52, child: Center(child: RasdLogo(size: 40))),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image, like the Login screen.
              const AppImage(
                asset: AppAssets.skyline,
                fit: BoxFit.cover,
                fallback: SkylineArt(),
              ),

              // Light overlay for readable text.
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [
                      const Color(0xFFF7FAFF).withValues(alpha: 0.96),
                      const Color(0xFFF7FAFF).withValues(alpha: 0.75),
                      const Color(0xFFF7FAFF).withValues(alpha: 0.15),
                    ],
                  ),
                ),
              ),

              // Foreground: avatar and welcome message.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    const CircleAvatar(
                      radius: 29,
                      backgroundColor: Color(0xFFE3EEF3),
                      child: Icon(
                        Icons.person,
                        size: 34,
                        color: Color(0xFF1E4D5C),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'مرحباً بك في رصد!',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.tr('citizenTagline'),
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard() {
    return InkWell(
      onTap: _comingSoon,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 128,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
          gradient: const LinearGradient(
            colors: [Color(0xFFF2FAF5), Color(0xFFD2EDDB)],
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('heroTitle'),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.tr('heroSub'),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              width: 150,
              height: 128,
              child: AppImage(asset: AppAssets.hero, fallback: HeroArt()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(CitizenHomeData data) {
    return SectionCard(
      icon: Icons.bar_chart_rounded,
      title: context.tr('mySummary'),
      child: Column(
        children: [
          Row(
            children: [
              StatCard(
                compact: true,
                value: data.pendingCount,
                label: context.tr('statusWaiting'),
                icon: Icons.error,
                bg: AppColors.newBg,
                fg: AppColors.newFg,
                onTap: () => context.go('/reports'),
              ),
              const SizedBox(width: 10),
              StatCard(
                compact: true,
                value: data.inProgressCount,
                label: context.tr('statusProgress'),
                icon: Icons.schedule,
                bg: AppColors.progressBg,
                fg: AppColors.progressFg,
                onTap: () => context.go('/reports'),
              ),
              const SizedBox(width: 10),
              StatCard(
                compact: true,
                value: data.resolvedCount,
                label: context.tr('statusDone'),
                icon: Icons.check_circle,
                bg: AppColors.doneBg,
                fg: AppColors.doneFg,
                onTap: () => context.go('/reports'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinkRow(
            context.tr('viewAllMine'),
            onTap: () => context.go('/reports'),
          ),
        ],
      ),
    );
  }

  Widget _buildLatestReport(ReportModel? report) {
    return SectionCard(
      icon: Icons.access_time_rounded,
      title: context.tr('latestUpdate'),
      child: report == null
          ? const Text('No reports submitted yet.')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: AppColors.primarySoft,
                      child: Icon(
                        Icons.edit_road_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            report.category,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '#${report.reportId}',
                            style: const TextStyle(color: AppColors.muted),
                          ),
                          const SizedBox(height: 6),
                          Text('Status: ${report.status}'),
                          Text(fmtDate(report.createdAt)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinkRow(
                  context.tr('viewAllMine'),
                  onTap: () => context.go('/reports'),
                ),
              ],
            ),
    );
  }

  Widget _buildNearbyAlerts() {
    return SectionCard(
      icon: Icons.location_on,
      title: context.tr('nearbyAlerts'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nearby alerts will be available when location '
            'and map services are connected.',
          ),
          const SizedBox(height: 8),
          LinkRow(context.tr('viewOnMap'), onTap: _comingSoon),
        ],
      ),
    );
  }

  Widget _buildRouteCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: AppDecor.card(),
      child: Row(
        children: [
          const SizedBox(
            width: 110,
            height: 100,
            child: AppImage(asset: AppAssets.road, fallback: RoadArt()),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('routeTitle'),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: _comingSoon,
                  child: Text(context.tr('checkRoute')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
