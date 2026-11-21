import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import '../../core/l10n/app_strings.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/widgets.dart';
import '../complaints/complaints_provider.dart';
import 'gps_selection.dart';

/// شاشة خريطة الشكاوى باستخدام OpenStreetMap وبيانات الإحداثيات الحقيقية.
class MapScreen extends ConsumerStatefulWidget {
  final bool selectionMode;

  const MapScreen({super.key, this.selectionMode = false});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  String? _selectedId;
  bool _satellite = false;
  final Set<ComplaintStatus> _visible = {...ComplaintStatus.values};

  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();
  LatLng? _myLocation;
  LatLng? _pickedLocation;
  double? _gpsAccuracyMeters;
  LatLng? _searchedLocation;
  bool _isSearching = false;
  bool _isLocating = false;

  static const _irbidCenter = LatLng(32.5525, 35.8493);

  @override
  void initState() {
    super.initState();
    if (widget.selectionMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _goToMyLocation();
      });
    }
  }

  void _openFilter(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ctx.tr('filterTitle'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
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

  Future<void> _goToMyLocation() async {
    if (_isLocating) return;
    setState(() => _isLocating = true);
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('يرجى تفعيل خدمة الموقع'),
            action: SnackBarAction(
              label: 'الإعدادات',
              onPressed: () => Geolocator.openLocationSettings(),
            ),
          ));
        }
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(permission == LocationPermission.deniedForever
                ? 'إذن الموقع مرفوض دائمًا. فعّله من إعدادات التطبيق.'
                : 'تم رفض إذن الموقع. أعد المحاولة للسماح به.'),
            action: permission == LocationPermission.deniedForever
                ? SnackBarAction(
                    label: 'الإعدادات',
                    onPressed: () => Geolocator.openAppSettings(),
                  )
                : null,
          ));
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      final point = LatLng(position.latitude, position.longitude);
      if (!mounted) return;
      setState(() {
        _myLocation = point;
        if (widget.selectionMode) {
          _pickedLocation = point;
          _gpsAccuracyMeters = position.accuracy;
        }
        _selectedId = null;
      });
      _mapController.move(point, 16);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('تعذر الحصول على موقعك')));
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _searchLocation() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() => _isSearching = true);
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'q': '$query, الأردن',
        'format': 'json',
        'limit': '1',
        'countrycodes': 'jo',
      });
      final response = await http.get(
        uri,
        headers: const {'User-Agent': 'RASD Flutter App'},
      );
      if (response.statusCode != 200) throw Exception('search failed');

      final results = jsonDecode(response.body) as List<dynamic>;
      if (results.isEmpty) throw Exception('no result');

      final result = results.first as Map<String, dynamic>;
      final point = LatLng(
        double.parse(result['lat'] as String),
        double.parse(result['lon'] as String),
      );
      if (!mounted) return;

      setState(() {
        _searchedLocation = point;
      });
      _mapController.move(point, 16);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لم يتم العثور على الموقع')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => widget.selectionMode ? context.pop() : context.go('/home'),
        ),
        title: Text(widget.selectionMode ? 'تحديد موقع الشكوى' : context.tr('mapTitle')),
        actions: widget.selectionMode
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.filter_alt_outlined),
                  onPressed: () => _openFilter(context),
                ),
              ],
      ),
      body: LayoutBuilder(builder: (context, box) {
        final h = box.maxHeight;
        final markers = <Marker>[];

        if (widget.selectionMode && _pickedLocation != null) {
          markers.add(Marker(
            point: _pickedLocation!,
            width: 50,
            height: 50,
            child: const Icon(Icons.location_on, size: 50, color: AppColors.primary),
          ));
        }

        if (_myLocation != null) {
          markers.add(Marker(
            point: _myLocation!,
            width: 34,
            height: 34,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2F80ED).withValues(alpha: .18),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2F80ED),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                ),
              ),
            ),
          ));
        }

        for (final c in shown) {
          if (c.latitude == null || c.longitude == null) continue;
          markers.add(Marker(
            point: LatLng(c.latitude!, c.longitude!),
            width: 48,
            height: 48,
            child: GestureDetector(
              onTap: () => setState(() => _selectedId = c.id),
              child: Icon(
                Icons.location_on,
                size: c.id == sel?.id ? 50 : 42,
                color: statusStyle(c.status).fg,
              ),
            ),
          ));
        }

        if (!widget.selectionMode && _searchedLocation != null) {
          markers.add(Marker(
            point: _searchedLocation!,
            width: 50,
            height: 50,
            child: const Icon(Icons.location_on, size: 50, color: Colors.red),
          ));
        }

        return Stack(children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _irbidCenter,
                initialZoom: 13,
                onTap: (_, point) {
                  if (!widget.selectionMode) setState(() => _selectedId = null);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: _satellite
                      ? 'https://tile.openstreetmap.fr/hot/{z}/{x}/{y}.png'
                      : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.rasd',
                  maxNativeZoom: 19,
                ),
                MarkerLayer(markers: markers),
              ],
            ),
          ),
          if (!widget.selectionMode) Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Material(
              elevation: 3,
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _searchLocation(),
                decoration: InputDecoration(
                  hintText: 'ابحث عن مكان أو عنوان',
                  prefixIcon: const Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  suffixIcon: _isSearching
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: _searchLocation,
                        ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 12,
            top: h * .38,
            child: Column(children: [
              _MapButton(Icons.my_location, _isLocating ? () {} : _goToMyLocation),
              const SizedBox(height: 10),
              _MapButton(Icons.layers_outlined, () {
                setState(() => _satellite = !_satellite);
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(context.tr('layerChanged'))));
              }),
            ]),
          ),
          if (widget.selectionMode)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(children: [
                          Text(_pickedLocation == null
                              ? 'بانتظار تحديد الموقع من GPS'
                              : 'الموقع ثابت على إحداثيات GPS المكتشفة'),
                          if (_gpsAccuracyMeters != null)
                            Text('دقة GPS: ±${_gpsAccuracyMeters!.toStringAsFixed(1)} متر'),
                          TextButton.icon(
                            onPressed: _isLocating ? null : _goToMyLocation,
                            icon: const Icon(Icons.refresh),
                            label: Text(_isLocating ? 'جارٍ تحديث الموقع...' : 'تحديث الموقع (Refresh Location)'),
                          ),
                        ]),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: _pickedLocation == null || _gpsAccuracyMeters == null
                          ? null
                          : () => context.pop(GpsSelection(
                                latitude: _pickedLocation!.latitude,
                                longitude: _pickedLocation!.longitude,
                                accuracyMeters: _gpsAccuracyMeters!,
                              )),
                      icon: const Icon(Icons.check),
                      label: const Text('تأكيد موقع GPS'),
                    ),
                  ],
                ),
              ),
            ),
          if (!widget.selectionMode && sel != null)
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
                        Text('#${sel.id}',
                            style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                        Text(sel.title,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
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
