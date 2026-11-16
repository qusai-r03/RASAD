import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class LocationConfirmationScreen extends StatefulWidget {
  final XFile image;
  final String description;
  final String category;
  final String severity;

  const LocationConfirmationScreen({
    super.key,
    required this.image,
    required this.description,
    required this.category,
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

  // GPS values will be provided by Member 4.
  double? latitude;
  double? longitude;
  double? accuracy;

  bool get hasValidLocation => latitude != null && longitude != null;

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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  // Will be connected to Member 4's GPS service.
  void _refreshLocation() {
    _showMessage('خدمة تحديد الموقع غير مربوطة بعد. سيتم ربطها مع Member 4.');
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
                      'سيتم تحديد موقع المشكلة تلقائيًا باستخدام GPS.',
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),

                    const SizedBox(height: 22),

                    // Map Placeholder
                    Container(
                      height: 280,

                      decoration: BoxDecoration(
                        color: const Color(0xFFE8EEF5),
                        borderRadius: BorderRadius.circular(18),

                        border: Border.all(
                          color: const Color(0xFFD6DFE8),
                          width: 2,
                        ),
                      ),

                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          Icon(Icons.location_on, size: 65, color: buttonBlue),

                          SizedBox(height: 14),

                          Text(
                            'معاينة موقع البلاغ',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: primaryBlue,
                            ),
                          ),

                          SizedBox(height: 10),

                          Text(
                            'بانتظار ربط الخريطة وخدمة GPS',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),

                          SizedBox(height: 12),

                          Text(
                            'المؤشر سيكون ثابتًا وغير قابل للسحب',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Location Status
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
                                  hasValidLocation
                                      ? 'تم تحديد الموقع'
                                      : 'بانتظار ربط GPS',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: hasValidLocation
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                ),
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

                    // GPS Information
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
                              'سيتم تحديد الموقع من GPS الجهاز، '
                              'ويمكن تحديثه عند توفر الخدمة.',
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

                    // Refresh Location Button
                    SizedBox(
                      height: 52,

                      child: OutlinedButton.icon(
                        onPressed: _refreshLocation,

                        icon: const Icon(Icons.refresh),

                        label: const Text(
                          'تحديث الموقع',
                          style: TextStyle(
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

                    // Report Summary
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

                    // Submit Report Button (Disabled Until Integration)
                    SizedBox(
                      height: 55,

                      child: ElevatedButton.icon(
                        onPressed: null,

                        icon: const Icon(Icons.send),

                        label: const Text(
                          'إرسال البلاغ',
                          style: TextStyle(
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

                    const SizedBox(height: 14),

                    const Text(
                      'الإرسال الفعلي سيتوفر بعد ربط GPS وقاعدة البيانات مع أعضاء الفريق.',
                      textAlign: TextAlign.center,

                      style: TextStyle(fontSize: 13, color: Colors.grey),
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
