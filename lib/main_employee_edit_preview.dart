
import 'package:flutter/material.dart';

import 'features/complaints/widgets/employee_report_editing_panel.dart';

void main() {
  runApp(const EmployeeEditPreviewApp());
}

class EmployeeEditPreviewApp extends StatelessWidget {
  const EmployeeEditPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RASD Employee Editing Preview',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF123B5D),
        ),
        useMaterial3: true,
      ),
      home: const EmployeeEditPreviewScreen(),
    );
  }
}

class EmployeeEditPreviewScreen extends StatefulWidget {
  const EmployeeEditPreviewScreen({super.key});

  @override
  State<EmployeeEditPreviewScreen> createState() =>
      _EmployeeEditPreviewScreenState();
}

class _EmployeeEditPreviewScreenState
    extends State<EmployeeEditPreviewScreen> {
  String _category = 'pothole';
  String _priority = 'medium';

  Future<void> _savePreview({
    required String category,
    required String priority,
  }) async {
    // Preview only: no Firebase or backend writes.
    setState(() {
      _category = category;
      _priority = priority;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Editing Preview'),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Card(
                color: Color(0xFFFFF3CD),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'PREVIEW ONLY: Changes are stored in '
                    'local screen state, not Firebase.',
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Report #RASD-TEST-001',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              EmployeeReportEditingPanel(
                key: ValueKey('$_category-$_priority'),
                initialCategory: _category,
                initialPriority: _priority,
                onSave: _savePreview,
              ),

              const SizedBox(height: 20),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Preview Values',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Category: $_category'),
                      Text('Priority: $_priority'),
                    ],
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
