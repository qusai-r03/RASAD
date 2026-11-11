import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/photo_box.dart';
import 'complaints_provider.dart';

/// تقديم شكوى جديدة (للمواطن). تُحفظ حالياً في الذاكرة فقط.
/// TODO(DB): كتابة المستند في Firestore ورفع الصورة إلى Storage.
/// TODO(Map): الموقع الآن نص حر؛ يُستبدل بإحداثيات GPS/اختيار من الخريطة.
/// TODO(AI): استدعاء خدمة التصنيف وتعبئة aiLabel/aiConfidence/priority.
class NewComplaintScreen extends ConsumerStatefulWidget {
  const NewComplaintScreen({super.key});

  @override
  ConsumerState<NewComplaintScreen> createState() => _NewComplaintScreenState();
}

class _NewComplaintScreenState extends ConsumerState<NewComplaintScreen> {
  final _form = GlobalKey<FormState>();
  final _desc = TextEditingController();
  final _loc = TextEditingController();
  String? _photo;

  @override
  void dispose() {
    _desc.dispose();
    _loc.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;

    final notifier = ref.read(complaintsProvider.notifier);
    final id = notifier.nextId();
    notifier.add(Complaint(
      id: id,
      title: _desc.text.trim(),
      status: ComplaintStatus.newC,
      date: DateTime.now(),
      location: _loc.text.trim(),
      description: _desc.text.trim(),
      localImagePath: _photo,
    ));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr('submitted'))));
    context.pushReplacement('/complaint/$id');
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Text(t, style: const TextStyle(fontWeight: FontWeight.w800)),
      );

  @override
  Widget build(BuildContext context) {
    String? req(String? v) => (v == null || v.trim().isEmpty) ? context.tr('required') : null;

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text(context.tr('newComplaint'))),
      body: Form(
        key: _form,
        child: ListView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), children: [
          _label(context.tr('addPhoto')),
          PhotoBox(
            path: _photo,
            label: context.tr('choosePhoto'),
            onPick: () async {
              final p = await pickPhoto(context);
              if (p != null) setState(() => _photo = p);
            },
            onRemove: () => setState(() => _photo = null),
          ),
          _label(context.tr('location')),
          TextFormField(
            controller: _loc,
            validator: req,
            decoration: AppDecor.input(hint: context.tr('locationHint'), icon: Icons.location_on_outlined),
          ),
          _label(context.tr('description')),
          TextFormField(
            controller: _desc,
            maxLines: 4,
            validator: req,
            decoration: AppDecor.input(hint: context.tr('descHint')),
          ),
        ]),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton(onPressed: _submit, child: Text(context.tr('submit'))),
        ),
      ),
    );
  }
}
