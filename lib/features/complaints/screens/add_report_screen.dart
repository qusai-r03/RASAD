import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'category_confirmation_screen.dart';

class AddReportScreen extends StatefulWidget {
  const AddReportScreen({super.key});

  @override
  State<AddReportScreen> createState() => _AddReportScreenState();
}

class _AddReportScreenState extends State<AddReportScreen> {
  final TextEditingController descriptionController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  XFile? selectedImage;
  Uint8List? previewBytes;
  bool isTakingPhoto = false;

  static const Color primaryBlue = Color(0xFF123B5D);
  static const Color buttonBlue = Color(0xFF0057C8);

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _pickPhoto(ImageSource source) async {
    if (isTakingPhoto) return;

    setState(() {
      isTakingPhoto = true;
    });

    try {
      debugPrint('CAMERA: Opening camera...');

      final XFile? photo = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );

      if (!mounted) return;

      if (photo != null) {
        final bytes = await photo.readAsBytes();
        if (!mounted) return;

        setState(() {
          selectedImage = photo;
          previewBytes = bytes;
        });

        _showMessage('تم اختيار الصورة بنجاح');
      } else {
        debugPrint('CAMERA: Photo capture cancelled');
      }
    } catch (e, stackTrace) {
      debugPrint('CAMERA ERROR: $e');

      debugPrintStack(label: 'CAMERA STACK TRACE', stackTrace: stackTrace);

      if (!mounted) return;

      _showMessage('تعذّر اختيار الصورة. حاول مرة أخرى.');
    } finally {
      if (mounted) {
        setState(() {
          isTakingPhoto = false;
        });
      }
    }
  }

  // Navigate to AI Category Confirmation
  void _nextStep() {
    if (selectedImage == null) {
      _showMessage('يرجى التقاط صورة قبل المتابعة');
      return;
    }

    final String description = descriptionController.text.trim();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryConfirmationScreen(
          image: selectedImage!,
          previewBytes: previewBytes!,
          description: description,
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
          title: const Text('إضافة بلاغ جديد'),
          centerTitle: true,
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
        ),

        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),

              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,

                  children: [
                    // Title
                    const Text(
                      'تصوير المشكلة',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'التقطي صورة واضحة للمشكلة التي تريدين الإبلاغ عنها.',
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),

                    const SizedBox(height: 24),

                    // Captured Image Preview
                    Container(
                      height: 250,
                      clipBehavior: Clip.antiAlias,

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),

                        border: Border.all(
                          color: const Color(0xFFD6DFE8),
                          width: 2,
                        ),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),

                      child: selectedImage == null
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,

                              children: [
                                Icon(
                                  Icons.camera_alt_outlined,
                                  size: 75,
                                  color: primaryBlue,
                                ),

                                SizedBox(height: 15),

                                Text(
                                  'لم يتم التقاط صورة بعد',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),

                                SizedBox(height: 8),

                                Text(
                                  'اضغطي على زر الكاميرا لالتقاط صورة',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            )
                          : Image.memory(
                              previewBytes!,
                              width: double.infinity,
                              height: 250,
                              fit: BoxFit.cover,

                              errorBuilder: (context, error, stackTrace) {
                                debugPrint('IMAGE PREVIEW ERROR: $error');

                                return const Center(
                                  child: Text('تعذر عرض الصورة'),
                                );
                              },
                            ),
                    ),

                    const SizedBox(height: 22),

                    // Camera Button
                    SizedBox(
                      height: 55,

                      child: ElevatedButton.icon(
                        onPressed: isTakingPhoto ? null : () => _pickPhoto(ImageSource.camera),

                        icon: isTakingPhoto
                            ? const SizedBox(
                                width: 20,
                                height: 20,

                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.camera_alt),

                        label: Text(
                          isTakingPhoto
                              ? 'جارٍ اختيار الصورة...'
                              : selectedImage == null
                              ? 'التقاط صورة'
                              : 'إعادة التقاط الصورة',

                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 35),

                    OutlinedButton.icon(
                      onPressed: isTakingPhoto ? null : () => _pickPhoto(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('اختيار صورة من المعرض'),
                    ),
                    const SizedBox(height: 16),

                    // Description Label
                    const Text(
                      'وصف المشكلة (اختياري)',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Description Text Field
                    TextField(
                      controller: descriptionController,
                      maxLines: 4,
                      maxLength: 500,

                      decoration: InputDecoration(
                        hintText: 'اكتبي تفاصيل إضافية عن المشكلة...',

                        hintStyle: const TextStyle(color: Colors.grey),

                        filled: true,
                        fillColor: Colors.white,

                        contentPadding: const EdgeInsets.all(16),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),

                          borderSide: const BorderSide(
                            color: Color(0xFFD6DFE8),
                          ),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),

                          borderSide: const BorderSide(
                            color: buttonBlue,
                            width: 2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

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

                    const SizedBox(height: 15),

                    const Text(
                      'سيتم تحديد موقع البلاغ تلقائيًا باستخدام GPS في خطوة التأكيد.',
                      textAlign: TextAlign.center,

                      style: TextStyle(fontSize: 13, color: Colors.grey),
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
