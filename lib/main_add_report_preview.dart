import 'package:flutter/material.dart';

import 'features/complaints/screens/add_report_screen.dart';

void main() {
  runApp(const AddReportPreviewApp());
}

class AddReportPreviewApp extends StatelessWidget {
  const AddReportPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RASD - Add Report Preview',
      home: AddReportScreen(),
    );
  }
}
