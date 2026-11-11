import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../core/services/report_service.dart';
import '../../../models/report_model.dart';
import '../../../models/user_role.dart';

import '../widgets/report_card.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String selectedStatus = 'All';

  final ReportService _reportService = ReportService();
  late Future<List<ReportModel>> _reportsFuture;

  @override
  void initState() {
    super.initState();
    _reportsFuture = _loadReports();
  }

  // TODO: Connect this method to the Reports UI after emulator setup.
  Future<List<ReportModel>> _loadReports() async {
    final user = roleService.getCurrentUser();
    if (user == null) {
      throw StateError('User is not authenticated.');
    }

    switch (user.role) {
      case UserRole.citizen:
        return _reportService.getCitizenReports(user.id);

      case UserRole.employee:
        final municipalityId = await _reportService.getEmployeeMunicipalityId(
          user.id,
        );

        return _reportService.getEmployeeReports(municipalityId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports'), centerTitle: true),
      body: Column(
        children: [
          SizedBox(
            height: 72,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  buildFilterChip('All'),
                  const SizedBox(width: 8),

                  buildFilterChip('Pending'),
                  const SizedBox(width: 8),

                  buildFilterChip('In Progress'),
                  const SizedBox(width: 8),

                  buildFilterChip('Resolved'),
                ],
              ),
            ),
          ),

          Expanded(
            child: FutureBuilder<List<ReportModel>>(
              future: _reportsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('Unable to load reports.'));
                }

                final reports = (snapshot.data ?? <ReportModel>[]).where((
                  report,
                ) {
                  return selectedStatus == 'All' ||
                      report.status == selectedStatus;
                }).toList();

                if (reports.isEmpty) {
                  return const Center(
                    child: Text('No reports found for this status.'),
                  );
                }

                return ListView.builder(
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final report = reports[index];

                    return ReportCard(
                      reportId: report.reportId,
                      category: report.category,
                      status: report.status,
                      date:
                          '${report.createdAt.day}/${report.createdAt.month}/${report.createdAt.year}',
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFilterChip(String status) {
    return ChoiceChip(
      label: Text(status),
      selected: selectedStatus == status,
      selectedColor: Colors.blue,
      onSelected: (selected) {
        setState(() {
          selectedStatus = status;
        });
      },
    );
  }
}
