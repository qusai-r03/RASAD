import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../core/services/report_service.dart';
import '../../../models/report_model.dart';
import '../../../models/user_role.dart';

import '../widgets/employee_report_editing_panel.dart';
import '../widgets/employee_report_review_panel.dart';
import '../widgets/official_category_editor.dart';
import '../widgets/report_category_comparison.dart';

class ReportDetailsScreen extends StatefulWidget {
  final String reportId;

  const ReportDetailsScreen({super.key, required this.reportId});

  @override
  State<ReportDetailsScreen> createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<ReportDetailsScreen> {
  final ReportService _reportService = ReportService();

  String _previewReviewStatus = 'pending';
  String? _previewOfficialCategory;

  late Future<ReportModel?> _reportFuture;

  @override
  void initState() {
    super.initState();

    _reportFuture = _reportService.getReportById(widget.reportId);
  }

  @override
  void didUpdateWidget(covariant ReportDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.reportId != widget.reportId) {
      _previewReviewStatus = 'pending';
      _previewOfficialCategory = null;

      _reportFuture = _reportService.getReportById(widget.reportId);
    }
  }

  // Save the actual report priority to Firebase.
  Future<void> _savePriority({
    required String category,
    required String priority,
  }) async {
    if (roleService.getCurrentUserRole() != UserRole.employee) {
      throw StateError('Only employees can update report priority.');
    }

    final reportId = widget.reportId;

    await _reportService.updateReportPriority(
      reportId: reportId,
      priority: priority,
    );

    if (!mounted || widget.reportId != reportId) return;

    setState(() {
      _reportFuture = _reportService.getReportById(reportId);
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$title:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildReportDetails(ReportModel report) {
    final imageUrl = report.imageUrl;

    final isEmployee = roleService.getCurrentUserRole() == UserRole.employee;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Report image.
        if (imageUrl != null && imageUrl.trim().isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              height: 220,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox(
                  height: 120,
                  child: Center(child: Text('Unable to load image')),
                );
              },
            ),
          ),

        const SizedBox(height: 20),

        // Report ID.
        Text(
          'Report #${report.reportId}',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 16),

        // Basic report information.
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _detailRow('Category', report.category),
                _detailRow('Status', report.status),
                _detailRow('Priority', report.priority),
                _detailRow('Created', _formatDate(report.createdAt)),
                _detailRow('Description', report.description),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Report location.
        const Text(
          'Location',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 8),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _detailRow('Latitude', report.latitude.toString()),
                _detailRow('Longitude', report.longitude.toString()),
              ],
            ),
          ),
        ),

        // Employee-only sections.
        if (isEmployee) ...[
          const SizedBox(height: 24),

          // 1. AI category comparison.
          ReportCategoryComparison(
            aiPrediction: report.aiPredictedCategory,
            citizenSelection: report.citizenSelectedCategory,
            officialCategory: report.officialCategory,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'The report currently contains a legacy category. '
              'AI prediction, citizen selection, and official category '
              'will appear when their separate values are available.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),

          const SizedBox(height: 16),

          // 2. Actual Firebase priority editing.
          EmployeeReportEditingPanel(
            key: ValueKey('${report.reportId}-${report.priority}'),
            initialCategory: report.category,
            initialPriority: report.priority,
            allowCategoryEditing: false,
            onSave: _savePriority,
          ),

          const SizedBox(height: 16),

          // 3. Official category correction preview.
          OfficialCategoryEditor(
            key: ValueKey('category-${report.reportId}'),
            initialCategory: _previewOfficialCategory,
            categories: const [
              'pothole',
              'garbage',
              'street_light',
              'water_leak',
            ],
            onCategoryChanged: (category) {
              setState(() {
                _previewOfficialCategory = category;
              });
            },
          ),

          if (_previewOfficialCategory != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Confirmed locally: $_previewOfficialCategory',
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          const SizedBox(height: 16),

          // 4. Employee review preview warning.
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Preview only - Review decisions are not saved to Firebase.',
              style: TextStyle(color: Colors.orange),
            ),
          ),

          const SizedBox(height: 8),

          // 5. Employee approval and rejection preview.
          EmployeeReportReviewPanel(
            key: ValueKey('review-${report.reportId}'),
            initialReviewStatus: _previewReviewStatus,
            onReview: (newStatus) async {
              setState(() {
                _previewReviewStatus = newStatus;
              });
            },
          ),

          const SizedBox(height: 24),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Details'), centerTitle: true),
      body: FutureBuilder<ReportModel?>(
        future: _reportFuture,
        builder: (context, snapshot) {
          // Loading state.
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error state.
          if (snapshot.hasError) {
            return const Center(child: Text('Unable to load report details.'));
          }

          final report = snapshot.data;

          // Empty state.
          if (report == null) {
            return const Center(child: Text('Report not found.'));
          }

          return _buildReportDetails(report);
        },
      ),
    );
  }
}
