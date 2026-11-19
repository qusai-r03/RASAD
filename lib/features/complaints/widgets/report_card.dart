import 'package:flutter/material.dart';

class ReportCard extends StatelessWidget {
  final String reportId;
  final String category;
  final String status;
  final String date;
  final String? imageUrl;

  const ReportCard({
    super.key,
    required this.reportId,
    required this.category,
    required this.status,
    required this.date,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Report image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 90,
                height: 90,
                child: hasImage
                    ? Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _imagePlaceholder();
                        },
                      )
                    : _imagePlaceholder(),
              ),
            ),

            const SizedBox(width: 16),

            // Report information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Report #$reportId',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text('Category: $category'),

                  const SizedBox(height: 6),

                  Text('Status: $status'),

                  const SizedBox(height: 6),

                  Text('Date: $date'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 32,
          color: Colors.grey,
        ),
      ),
    );
  }
}
