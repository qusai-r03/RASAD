import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/report_submission_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

class LocationConfirmationScreen extends StatefulWidget {
  final XFile image;
  final String description;
  final String category;
  final String predictedCategory;
  final String severity;

  const LocationConfirmationScreen({
    super.key,
    required this.image,
    required this.description,
    required this.category,
    required this.predictedCategory,
    required this.severity,
  });

  @override
  State<LocationConfirmationScreen> createState() =>
      _LocationConfirmationScreenState();
}

class _LocationConfirmationScreenState
    extends State<LocationConfirmationScreen> {
  static const Color primaryBlue = Color(0xFF123B5D);
  static const Color buttonBlue = Color(0xFF0057C8);

  double? latitude;
  double? longitude;
  double? accuracy;

  bool isSubmitting = false;
  bool isLoadingLocation = false;
  String locationStatus = 'بانتظار تحديد الموقع';

  bool get hasValidLocation => latitude != null && longitude != null;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _refreshLocation();
      }
    });
  }

  String get severityText {
    switch (widget.severity) {
      case 'خفيفة':
        return 'خطورة خفيفة';
      case 'متوسطة':
        return 'خطورة متوسطة';
      case 'عالية':
        return 'خطورة عالية';
      default:
        return 'غير محددة';
    }
  }

  Color get severityColor {
    switch (widget.severity) {
      case 'خفيفة':
        return Colors.green;
      case 'متوسطة':
        return Colors.orange;
      case 'عالية':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _submitReport() async {
    if (isSubmitting || isLoadingLocation || !hasValidLocation) return;
    setState(() => isSubmitting = true);
    try {
      final id = await ReportSubmissionService().submitReport(
        image: widget.image,
        category: widget.category,
        predictedCategory: widget.predictedCategory,
        accuracyMeters: accuracy,
        description: widget.description,
        latitude: latitude!,
        longitude: longitude!,
      );
      if (!mounted) return;
      _showMessage('تم إرسال البلاغ بنجاح. رقم البلاغ: $id');
      context.go('/reports');
    } on FormatException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage('تعذر تأكيد الإرسال. تحقق من الاتصال بالخادم ومن قائمة شكاواي');
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  Future<void> _refreshLocation() async {
    if (isLoadingLocation) return;

    setState(() {
      isLoadingLocation = true;
      locationStatus = 'جاري تحديد الموقع...';
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (!mounted) return;

        setState(() {
          locationStatus = 'يرجى تفعيل GPS';
        });

        _showMessage('يرجى تفعيل خدمة الموقع في الجهاز');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        if (!mounted) return;

        setState(() {
          locationStatus = 'تم رفض صلاحية الموقع';
        });

        _showMessage('يرجى السماح للتطبيق باستخدام الموقع');
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;

        setState(() {
          locationStatus = 'صلاحية الموقع مرفوضة بشكل دائم';
        });

        _showMessage('يرجى تفعيل صلاحية الموقع من إعدادات التطبيق');

        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );

      if (!mounted) return;

      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
        accuracy = position.accuracy;

        locationStatus = 'تم تحديد الموقع بنجاح';
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        locationStatus = hasValidLocation
            ? 'تعذر تحديث الموقع، آخر موقع ما زال محفوظًا'
            : 'تعذر تحديد الموقع';
      });

      _showMessage('تعذر الحصول على الموقع. تأكدي من تشغيل GPS وحاولي مجددًا.');
    } finally {
      if (mounted) {
        setState(() {
          isLoadingLocation = false;
        });
      }
    }
  }

  Widget _buildMap() {
    if (!hasValidLocation) {
      return Container(
        height: 280,
        decoration: BoxDecoration(
          color: const Color(0xFFE8EEF5),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFD6DFE8), width: 2),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoadingLocation)
                const CircularProgressIndicator(color: buttonBlue)
              else
                const Icon(Icons.location_on, size: 65, color: buttonBlue),

              const SizedBox(height: 15),

              const Text(
                'معاينة موقع البلاغ',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                locationStatus,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    final location = LatLng(latitude!, longitude!);

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 280,
        child: FlutterMap(
          key: ValueKey('${latitude!}_${longitude!}'),
          options: MapOptions(
            initialCenter: location,
            initialZoom: 17,

            // The user cannot move the map or marker.
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.none,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.rasd.city_issue_reporter',
            ),

            MarkerLayer(
              markers: [
                Marker(
                  point: location,
                  width: 60,
                  height: 60,
                  child: const Icon(
                    Icons.location_on,
                    size: 55,
                    color: buttonBlue,
                  ),
                ),
              ],
            ),

            const RichAttributionWidget(
              attributions: [
                TextSourceAttribution('OpenStreetMap contributors'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: const Text('تأكيد موقع البلاغ'),
          centerTitle: true,
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'تأكيد موقع البلاغ',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'أرسل البلاغ وأنت بالقرب من المشكلة حتى يحدد GPS موقعها بدقة.',
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),

                    const SizedBox(height: 22),

                    _buildMap(),

                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(17),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFD6DFE8)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.my_location,
                            color: buttonBlue,
                            size: 28,
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'الموقع الحالي',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: primaryBlue,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  locationStatus,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: hasValidLocation
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                ),

                                if (hasValidLocation) ...[
                                  const SizedBox(height: 8),

                                  Text(
                                    'Latitude: ${latitude!.toStringAsFixed(6)}',
                                    textDirection: TextDirection.ltr,
                                    style: const TextStyle(fontSize: 12),
                                  ),

                                  Text(
                                    'Longitude: ${longitude!.toStringAsFixed(6)}',
                                    textDirection: TextDirection.ltr,
                                    style: const TextStyle(fontSize: 12),
                                  ),

                                  if (accuracy != null)
                                    Text(
                                      'Accuracy: ${accuracy!.toStringAsFixed(1)} m',
                                      textDirection: TextDirection.ltr,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                ],
                              ],
                            ),
                          ),

                          Icon(
                            hasValidLocation
                                ? Icons.check_circle
                                : Icons.access_time,
                            color: hasValidLocation
                                ? Colors.green
                                : Colors.grey,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F1FF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, color: buttonBlue),

                          SizedBox(width: 10),

                          Expanded(
                            child: Text(
                              'لا يمكن تحريك مؤشر الموقع يدويًا. '
                              'يتم تحديد الموقع باستخدام GPS الجهاز، '
                              'ويمكن تحديثه باستخدام الزر أدناه.',
                              style: TextStyle(
                                fontSize: 14,
                                color: primaryBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: isSubmitting || isLoadingLocation ? null : _refreshLocation,
                        icon: const Icon(Icons.refresh),
                        label: Text(
                          isLoadingLocation
                              ? 'جاري التحديث...'
                              : 'تحديث الموقع',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: buttonBlue,
                          side: const BorderSide(color: buttonBlue, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFD6DFE8)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ملخص البلاغ',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: primaryBlue,
                            ),
                          ),

                          const SizedBox(height: 15),

                          const Text(
                            'تصنيف المشكلة',
                            style: TextStyle(color: Colors.grey),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            widget.category,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 14),

                          const Text(
                            'مستوى الخطورة (تجريبي)',
                            style: TextStyle(color: Colors.grey),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            severityText,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: severityColor,
                            ),
                          ),

                          const SizedBox(height: 14),

                          const Text(
                            'الوصف',
                            style: TextStyle(color: Colors.grey),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            widget.description.isEmpty
                                ? 'لا يوجد وصف إضافي'
                                : widget.description,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: hasValidLocation && !isLoadingLocation && !isSubmitting
                            ? _submitReport
                            : null,
                        icon: const Icon(Icons.send),
                        label: Text(
                          isSubmitting ? 'جارٍ إرسال البلاغ…' : 'إرسال البلاغ',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonBlue,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFF9EB6D1),
                          disabledForegroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
