import 'package:flutter/material.dart';

class ReportCard extends StatelessWidget {
  final String reportId;
  final String category;
  final String status;
  final String date;

  const ReportCard({
    super.key,
    required this.reportId,
    required this.category,
    required this.status,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Report #$reportId',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text('Category: $category'),

              const SizedBox(height: 8),

              Text('Status: $status'),

              const SizedBox(height: 8),

              Text('Date: $date'),
            ],
          ),
        ),
      ),
    );
  }
}
