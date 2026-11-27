import 'package:flutter/material.dart';

import '../../../app/router.dart' show roleService;
import '../../../core/services/report_service.dart';
import '../../../models/user_role.dart';
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

  bool _sendingCorrection = false;

  Future<void> _requestCorrection(String reportId) async {
    if (_sendingCorrection) return;
    var message = '';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, refresh) => AlertDialog(
          title: const Text('الإبلاغ عن معلومات غير صحيحة'),
          content: TextField(
            autofocus: true,
            minLines: 2,
            maxLines: 4,
            maxLength: 1000,
            decoration: const InputDecoration(labelText: 'ما المعلومة التي تحتاج إلى تصحيح؟'),
            onChanged: (value) => refresh(() => message = value.trim()),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
            FilledButton(
              onPressed: message.isEmpty ? null : () => Navigator.pop(dialogContext, true),
              child: const Text('إرسال الطلب'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || confirmed != true) return;
    setState(() => _sendingCorrection = true);
    try {
      await _reportService.requestCorrection(reportId, message);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال طلب التصحيح')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذّر إرسال طلب التصحيح')));
      }
    } finally {
      if (mounted) setState(() => _sendingCorrection = false);
    }
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
        if (roleService.getCurrentUserRole() == UserRole.citizen &&
            roleService.getCurrentUser()?.id == report.citizenId)
          OutlinedButton.icon(
            onPressed: _sendingCorrection ? null : () => _requestCorrection(report.reportId),
            icon: const Icon(Icons.flag_outlined),
            label: const Text('الإبلاغ عن معلومات غير صحيحة'),
          ),
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
