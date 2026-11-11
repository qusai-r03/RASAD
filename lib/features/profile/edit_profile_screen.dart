import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';
import '../auth/current_user_provider.dart';

/// تعديل الاسم والمنطقة. يحدّث المستخدم الحالي في الذاكرة.
/// TODO(DB): حفظ التعديل في users/{uid} داخل Firestore.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _region;

  @override
  void initState() {
    super.initState();
    final u = ref.read(currentUserProvider);
    _name = TextEditingController(text: u?.name ?? '');
    _region = TextEditingController(text: u?.region ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _region.dispose();
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    final u = ref.read(currentUserProvider);
    if (u != null) {
      ref.read(currentUserProvider.notifier).state =
          AppUser(id: u.id, name: _name.text.trim(), region: _region.text.trim(), role: u.role);
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr('saved'))));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    String? req(String? v) => (v == null || v.trim().isEmpty) ? context.tr('required') : null;
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text(context.tr('editTitle'))),
      body: Form(
        key: _form,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          TextFormField(controller: _name, validator: req, decoration: AppDecor.input(hint: context.tr('fullName'), icon: Icons.person_outline)),
          const SizedBox(height: 12),
          TextFormField(controller: _region, validator: req, decoration: AppDecor.input(hint: context.tr('region'), icon: Icons.location_city_outlined)),
        ]),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton(onPressed: _save, child: Text(context.tr('save'))),
        ),
      ),
    );
  }
}
