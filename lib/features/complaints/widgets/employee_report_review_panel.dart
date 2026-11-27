import 'package:flutter/material.dart';

class EmployeeReportReviewPanel extends StatefulWidget {
  final String initialReviewStatus;
  final bool isPreview;

  final Future<void> Function(String reviewStatus) onReview;

  const EmployeeReportReviewPanel({
    super.key,
    required this.initialReviewStatus,
    required this.onReview,
    this.isPreview = true,
  });
  @override
  State<EmployeeReportReviewPanel> createState() =>
      _EmployeeReportReviewPanelState();
}

class _EmployeeReportReviewPanelState extends State<EmployeeReportReviewPanel> {
  late String _reviewStatus;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _reviewStatus = widget.initialReviewStatus;
  }

  @override
  void didUpdateWidget(covariant EmployeeReportReviewPanel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialReviewStatus != widget.initialReviewStatus) {
      _reviewStatus = widget.initialReviewStatus;
    }
  }

  Color _statusColor() {
    switch (_reviewStatus) {
      case 'approved':
        return Colors.green;

      case 'rejected':
        return Colors.red;

      default:
        return Colors.orange;
    }
  }

  String _statusLabel() {
    switch (_reviewStatus) {
      case 'approved':
        return 'Approved';

      case 'rejected':
        return 'Rejected';

      default:
        return 'Awaiting Review';
    }
  }

  Future<void> _confirmReview(String newStatus) async {
    if (_isSaving || newStatus == _reviewStatus) return;

    final action = newStatus == 'approved' ? 'approve' : 'reject';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Review'),
          content: Text('Are you sure you want to $action this report?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.onReview(newStatus);

      if (!mounted) return;

      setState(() {
        _reviewStatus = newStatus;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isPreview
                ? 'Review decision confirmed locally. Not saved to Firebase.'
                : newStatus == 'approved'
                ? 'Report approved successfully.'
                : 'Report rejected successfully.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to update review status.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
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
              'Employee Report Review',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            const Text(
              'Current Review Status',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 8),

            Chip(
              label: Text(_statusLabel()),
              backgroundColor: _statusColor().withValues(alpha: 0.15),
              side: BorderSide(color: _statusColor()),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSaving || _reviewStatus == 'approved'
                        ? null
                        : () => _confirmReview('approved'),
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Approve'),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isSaving || _reviewStatus == 'rejected'
                        ? null
                        : () => _confirmReview('rejected'),
                    icon: const Icon(Icons.cancel),
                    label: const Text('Reject'),
                  ),
                ),
              ],
            ),

            if (_isSaving) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }
}
