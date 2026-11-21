import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../models/user_role.dart';
import '../widgets/employee_report_editing_panel.dart';
import '../../../core/services/report_service.dart';
import '../../../models/report_model.dart';

class ReportDetailsScreen extends StatefulWidget {
  final String reportId;

  const ReportDetailsScreen({super.key, required this.reportId});

  @override
  State<ReportDetailsScreen> createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<ReportDetailsScreen> {
  final ReportService _reportService = ReportService();

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
      _reportFuture = _reportService.getReportById(widget.reportId);
    }
  }

  Future<void> _savePriority({
    required String category,
    required String priority,
  }) async {
    if (roleService.getCurrentUserRole() != UserRole.employee) {
      throw StateError('Only employees can update report priority.');
    }

    await _reportService.updateReportPriority(
      reportId: widget.reportId,
      priority: priority,
    );

    if (!mounted) return;

    setState(() {
      _reportFuture = _reportService.getReportById(widget.reportId);
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

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
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

        Text(
          'Report #${report.reportId}',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 16),

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
        if (roleService.getCurrentUserRole() == UserRole.employee) ...[
          const SizedBox(height: 24),

          EmployeeReportEditingPanel(
            key: ValueKey('${report.reportId}-${report.priority}'),
            initialCategory: report.category,
            initialPriority: report.priority,
            allowCategoryEditing: false,
            onSave: _savePriority,
          ),
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
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Unable to load report details.'));
          }

          final report = snapshot.data;

          if (report == null) {
            return const Center(child: Text('Report not found.'));
          }

          return _buildReportDetails(report);
        },
      ),
    );
  }
}
