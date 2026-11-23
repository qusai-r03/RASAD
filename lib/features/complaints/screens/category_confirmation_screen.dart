import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'location_confirmation_screen.dart';

class CategoryConfirmationScreen extends StatefulWidget {
  final XFile image;
  final Uint8List previewBytes;
  final String description;

  const CategoryConfirmationScreen({
    super.key,
    required this.image,
    required this.previewBytes,
    required this.description,
  });

  @override
  State<CategoryConfirmationScreen> createState() =>
      _CategoryConfirmationScreenState();
}

class _CategoryConfirmationScreenState
    extends State<CategoryConfirmationScreen> {
  static const Color primaryBlue = Color(0xFF123B5D);
  static const Color buttonBlue = Color(0xFF0057C8);

  // Mock AI results until the real AI model is integrated.
  String selectedCategory = 'حفرة في الطريق';
  final String severityLevel = 'عالية';

  // Temporary categories. Replace with the team's official categories.
  final List<String> categories = [
    'حفرة في الطريق',
    'نفايات متراكمة',
    'إنارة شوارع',
    'تسرب مياه',
  ];

  Color get severityColor {
    switch (severityLevel) {
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

  IconData get severityIcon {
    switch (severityLevel) {
      case 'خفيفة':
        return Icons.check_circle_outline;
      case 'متوسطة':
        return Icons.warning_amber_rounded;
      case 'عالية':
        return Icons.error_outline;
      default:
        return Icons.info_outline;
    }
  }

  void _showCategoryPicker() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'تعديل تصنيف المشكلة',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'اختاري التصنيف المناسب للمشكلة',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ...categories.map(
                    (category) => ListTile(
                      title: Text(category),
                      leading: Icon(
                        selectedCategory == category
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: buttonBlue,
                      ),
                      onTap: () {
                        setState(() {
                          selectedCategory = category;
                        });

                        Navigator.pop(sheetContext);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Navigate to Location Confirmation
  void _nextStep() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationConfirmationScreen(
          image: widget.image,
          description: widget.description,
          category: selectedCategory,
          severity: severityLevel,
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
          title: const Text('مراجعة التصنيف'),
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
                    // Captured Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.memory(
                        widget.previewBytes,
                        height: 230,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 230,
                            color: Colors.white,
                            child: const Center(child: Text('تعذر عرض الصورة')),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // AI Category Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F1FF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  size: 18,
                                  color: buttonBlue,
                                ),
                                SizedBox(width: 7),
                                Text(
                                  'اقتراح تجريبي',
                                  style: TextStyle(
                                    color: buttonBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            'تصنيف المشكلة',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            selectedCategory,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // AI Severity Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: severityColor.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: severityColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'مستوى الخطورة (تجريبي)',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Icon(
                                severityIcon,
                                color: severityColor,
                                size: 31,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'خطورة $severityLevel',
                                style: TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.bold,
                                  color: severityColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Edit Category Button
                    OutlinedButton.icon(
                      onPressed: _showCategoryPicker,
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text(
                        'تعديل التصنيف',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: buttonBlue,
                        side: const BorderSide(color: buttonBlue, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Next Button
                    SizedBox(
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _nextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'التالي',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      'سيتم تأكيد الموقع تلقائيًا قبل إرسال البلاغ.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'التصنيف ومستوى الخطورة المعروضان حاليًا بيانات تجريبية، وليسا نتيجة تحليل فعلي للصورة.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
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
