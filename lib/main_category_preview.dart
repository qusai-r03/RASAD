import 'package:flutter/material.dart';

import 'features/complaints/widgets/report_category_comparison.dart';

void main() {
  runApp(const CategoryPreviewApp());
}

class CategoryPreviewApp extends StatelessWidget {
  const CategoryPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RASD Category Preview',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF123B5D)),
        useMaterial3: true,
      ),
      home: const CategoryPreviewScreen(),
    );
  }
}

class CategoryPreviewScreen extends StatelessWidget {
  const CategoryPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Comparison Preview'),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: const [
              Card(
                color: Color(0xFFFFF3CD),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'PREVIEW ONLY: These are sample values, '
                    'not actual Firebase or AI results.',
                  ),
                ),
              ),

              SizedBox(height: 20),

              Text(
                'Example Report',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 16),

              ReportCategoryComparison(
                aiPrediction: 'garbage',
                citizenSelection: 'pothole',
                officialCategory: 'pothole',
              ),

              SizedBox(height: 24),

              Text(
                'Example With Missing Data',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 16),

              ReportCategoryComparison(officialCategory: 'pothole'),
            ],
          ),
        ),
      ),
    );
  }
}
