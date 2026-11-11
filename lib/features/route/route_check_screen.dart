import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/widgets.dart';
import '../complaints/complaints_provider.dart';

/// فحص الطريق. ⚠️ النتيجة تجريبية: تعرض الشكاوى غير المنجزة.
/// TODO(Map): الحصول على مسار (Directions API) ثم استعلام جغرافي عن الشكاوى القريبة منه.
class RouteCheckScreen extends ConsumerStatefulWidget {
  const RouteCheckScreen({super.key});

  @override
  ConsumerState<RouteCheckScreen> createState() => _RouteCheckScreenState();
}

class _RouteCheckScreenState extends ConsumerState<RouteCheckScreen> {
  final _from = TextEditingController();
  final _to = TextEditingController();
  bool _checked = false;

  @override
  void dispose() {
    _from.dispose();
    _to.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final issues = ref.watch(complaintsProvider).where((c) => c.status != ComplaintStatus.done).toList();
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text(context.tr('checkRoute'))),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        TextField(controller: _from, decoration: AppDecor.input(hint: context.tr('from'), icon: Icons.trip_origin)),
        const SizedBox(height: 10),
        TextField(controller: _to, decoration: AppDecor.input(hint: context.tr('to'), icon: Icons.location_on_outlined)),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: () => setState(() => _checked = true),
          icon: const Icon(Icons.alt_route_rounded),
          label: Text(context.tr('check')),
        ),
        if (_checked) ...[
          const SizedBox(height: 20),
          Text(
            issues.isEmpty ? context.tr('noIssues') : '${context.tr('routeResults')} (${issues.length})',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(context.tr('demoResult'), style: const TextStyle(fontSize: 12, color: AppColors.muted)),
          const SizedBox(height: 10),
          for (final c in issues) ComplaintTile(c, onTap: () => context.push('/complaint/${c.id}')),
        ],
      ]),
    );
  }
}
