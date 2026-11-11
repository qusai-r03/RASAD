import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/widgets.dart';
import '../auth/current_user_provider.dart';
import 'complaints_provider.dart';

/// قائمة الشكاوى بتبويبات (الكل / جديدة / قيد المعالجة / تم الإنجاز).
/// مؤقتة ببيانات وهمية: عضو الشكاوى يستبدلها لاحقاً بالبيانات الحقيقية.
/// يقبل ?status=new|progress|done من بطاقات الرئيسية.
class ReportsScreen extends ConsumerStatefulWidget {
  final String? statusFilter;
  const ReportsScreen({super.key, this.statusFilter});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  ComplaintStatus? _filter;
  bool _searching = false;
  final _query = TextEditingController();

  static ComplaintStatus? _parse(String? s) => switch (s) {
        'new' => ComplaintStatus.newC,
        'progress' => ComplaintStatus.inProgress,
        'done' => ComplaintStatus.done,
        _ => null,
      };

  @override
  void initState() {
    super.initState();
    _filter = _parse(widget.statusFilter);
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ReportsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.statusFilter != widget.statusFilter) _filter = _parse(widget.statusFilter);
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(currentUserProvider)?.role ?? UserRole.citizen;
    final all = ref.watch(complaintsProvider);
    final q = _query.text.trim();
    final list = all
        .where((c) => _filter == null || c.status == _filter)
        .where((c) => q.isEmpty || c.id.contains(q) || c.title.contains(q) || c.location.contains(q))
        .toList();

    final tabs = <(ComplaintStatus?, String)>[
      (null, 'tabAll'),
      (ComplaintStatus.newC, 'tabNew'),
      (ComplaintStatus.inProgress, 'tabProgress'),
      (ComplaintStatus.done, 'tabDone'),
    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/home')),
        title: _searching
            ? TextField(
                controller: _query,
                autofocus: true,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(hintText: context.tr('searchHint'), border: InputBorder.none),
              )
            : Text(context.tr(role == UserRole.employee ? 'reportsTitle' : 'navMine')),
        actions: [
          IconButton(
            icon: Icon(_searching ? Icons.close : Icons.search),
            onPressed: () => setState(() {
              _searching = !_searching;
              if (!_searching) _query.clear();
            }),
          ),
        ],
      ),
      body: Column(children: [
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              for (final t in tabs)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: ChoiceChip(
                    label: Text(context.tr(t.$2)),
                    selected: _filter == t.$1,
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _filter = t.$1),
                    selectedColor: AppColors.primary,
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    labelStyle: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: _filter == t.$1 ? Colors.white : AppColors.muted,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: list.isEmpty
              ? Center(child: Text(context.tr('empty'), style: const TextStyle(color: AppColors.muted)))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  children: [
                    for (final c in list) ComplaintTile(c, onTap: () => context.push('/complaint/${c.id}')),
                  ],
                ),
        ),
      ]),
    );
  }
}
