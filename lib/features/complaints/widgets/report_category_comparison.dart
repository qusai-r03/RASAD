import 'package:flutter/material.dart';

class ReportCategoryComparison extends StatelessWidget {
  final String? aiPrediction;
  final String? citizenSelection;
  final String? officialCategory;

  const ReportCategoryComparison({
    super.key,
    this.aiPrediction,
    this.citizenSelection,
    this.officialCategory,
  });

  Widget _buildCategoryRow({
    required String title,
    required String? value,
    required IconData icon,
    required Color color,
  }) {
    final hasValue = value != null && value.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: color),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),

                const SizedBox(height: 4),

                Text(
                  hasValue ? value : 'Not available',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: hasValue ? Colors.black87 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Report Classification',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            _buildCategoryRow(
              title: 'AI Prediction',
              value: aiPrediction,
              icon: Icons.smart_toy_outlined,
              color: Colors.purple,
            ),

            const Divider(),

            _buildCategoryRow(
              title: 'Citizen Selection',
              value: citizenSelection,
              icon: Icons.person_outline,
              color: Colors.blue,
            ),

            const Divider(),

            _buildCategoryRow(
              title: 'Official Category',
              value: officialCategory,
              icon: Icons.verified_outlined,
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}
