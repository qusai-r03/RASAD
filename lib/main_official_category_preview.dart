import 'package:flutter/material.dart';

import 'features/complaints/widgets/official_category_editor.dart';

void main() {
  runApp(const OfficialCategoryPreviewApp());
}

class OfficialCategoryPreviewApp extends StatelessWidget {
  const OfficialCategoryPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF123B5D)),
        useMaterial3: true,
      ),
      home: const OfficialCategoryPreviewScreen(),
    );
  }
}

class OfficialCategoryPreviewScreen extends StatefulWidget {
  const OfficialCategoryPreviewScreen({super.key});

  @override
  State<OfficialCategoryPreviewScreen> createState() =>
      _OfficialCategoryPreviewScreenState();
}

class _OfficialCategoryPreviewScreenState
    extends State<OfficialCategoryPreviewScreen> {
  String? _confirmedCategory;

  // Temporary values for UI testing only.
  static const categories = [
    'pothole',
    'garbage',
    'street_light',
    'water_leak',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Official Category Preview')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              OfficialCategoryEditor(
                initialCategory: _confirmedCategory,
                categories: categories,
                onCategoryChanged: (category) {
                  setState(() {
                    _confirmedCategory = category;
                  });
                },
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Confirmed locally: '
                    '${_confirmedCategory ?? "None"}',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
