import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/widgets.dart';
import '../complaints/complaints_provider.dart';

/// ⚠️ شاشة خريطة مؤقتة (رسم وهمي بدبابيس من الشكاوى الوهمية).
/// عضو الخريطة يستبدلها بـ google_maps_flutter مع الإبقاء على بطاقة الشكوى السفلية.
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  String? _selectedId;
  bool _satellite = false;
  final Set<ComplaintStatus> _visible = {...ComplaintStatus.values};

  // مواضع الدبابيس كنسب من حجم الخريطة (لكل شكوى حسب ترتيبها).
  static const _pos = [Offset(.30, .22), Offset(.66, .30), Offset(.78, .50), Offset(.28, .55)];

  void _openFilter(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(ctx.tr('filterTitle'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Wrap(spacing: 8, children: [
                for (final s in ComplaintStatus.values)
                  FilterChip(
                    label: Text(ctx.tr(statusStyle(s).key)),
                    selected: _visible.contains(s),
                    onSelected: (v) {
                      setState(() => v ? _visible.add(s) : _visible.remove(s));
                      setSheet(() {});
                    },
                  ),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final complaints = ref.watch(complaintsProvider);
    final shown = complaints.where((c) => _visible.contains(c.status)).toList();
    Complaint? found;
    for (final c in shown) {
      if (c.id == _selectedId) found = c;
    }
    final Complaint? sel = found ?? (shown.isEmpty ? null : shown.first);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/home')),
        title: Text(context.tr('mapTitle')),
        actions: [IconButton(icon: const Icon(Icons.filter_alt_outlined), onPressed: () => _openFilter(context))],
      ),
      body: LayoutBuilder(builder: (context, box) {
        final w = box.maxWidth, h = box.maxHeight;
        return Stack(children: [
          Positioned.fill(child: CustomPaint(painter: _FakeMapPainter(_satellite))),
          // موقعي الحالي
          Positioned(
            left: w * .5 - 45,
            top: h * .42 - 45,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(color: const Color(0xFF2F80ED).withValues(alpha: .15), shape: BoxShape.circle),
              child: Center(
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2F80ED),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                ),
              ),
            ),
          ),
          for (var i = 0; i < complaints.length && i < _pos.length; i++)
            if (_visible.contains(complaints[i].status))
              Positioned(
              left: w * _pos[i].dx - 22,
              top: h * _pos[i].dy - 44,
              child: GestureDetector(
                onTap: () => setState(() => _selectedId = complaints[i].id),
                child: Icon(
                  Icons.location_on,
                  size: complaints[i].id == sel?.id ? 50 : 42,
                  color: statusStyle(complaints[i].status).fg,
                ),
              ),
            ),
          Positioned(
            right: 12,
            top: h * .38,
            child: Column(children: [
              _MapButton(Icons.my_location, () {
                setState(() => _selectedId = null);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr('myLocation'))));
              }),
              const SizedBox(height: 10),
              _MapButton(Icons.layers_outlined, () {
                setState(() => _satellite = !_satellite);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr('layerChanged'))));
              }),
            ]),
          ),
          if (sel != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: AppDecor.card(),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Row(children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('#${sel.id}', style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                        Text(sel.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        StatusChip(sel.status),
                      ]),
                    ),
                    const SizedBox(width: 10),
                    ComplaintThumb(sel, width: 84, height: 70),
                  ]),
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: () => context.push('/complaint/${sel.id}'),
                    child: Text(context.tr('viewDetails')),
                  ),
                ]),
              ),
            ),
        ]);
      }),
    );
  }
}

class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MapButton(this.icon, this.onTap);

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(width: 44, height: 44, child: Icon(icon, color: AppColors.text)),
        ),
      );
}

class _FakeMapPainter extends CustomPainter {
  final bool satellite;
  const _FakeMapPainter(this.satellite);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = satellite ? const Color(0xFF3F5A45) : const Color(0xFFE9EFE9));

    final park = Paint()..color = satellite ? const Color(0xFF2F4A37) : const Color(0xFFCFE6D3);
    final road = satellite ? const Color(0xFF9AA79D) : Colors.white;
    void parkAt(double l, double t, double w, double h) => canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(size.width * l, size.height * t, size.width * w, size.height * h), const Radius.circular(18)),
          park,
        );
    parkAt(.05, .08, .22, .16);
    parkAt(.62, .58, .3, .2);

    final big = Paint()
      ..color = road
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    final small = Paint()
      ..color = road
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    Offset p(double x, double y) => Offset(size.width * x, size.height * y);

    canvas.drawLine(p(-.05, .35), p(1.05, .45), big);
    canvas.drawLine(p(.45, -.05), p(.55, 1.05), big);
    canvas.drawLine(p(-.05, .75), p(1.05, .62), small);
    canvas.drawLine(p(.15, -.05), p(.05, 1.05), small);
    canvas.drawLine(p(.85, -.05), p(.92, 1.05), small);
    canvas.drawLine(p(-.05, .15), p(1.05, .2), small);
  }

  @override
  bool shouldRepaint(covariant _FakeMapPainter old) => old.satellite != satellite;
}
