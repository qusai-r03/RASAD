import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';

/// تغيير كلمة المرور: تحقق من الحقول فقط حالياً.
/// TODO(Auth): إعادة المصادقة بالكلمة الحالية ثم user.updatePassword(...) في Firebase Auth.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _cur = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _cur.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr('passChanged'))));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    String? req(String? v) => (v == null || v.isEmpty) ? context.tr('required') : null;
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text(context.tr('changePass'))),
      body: Form(
        key: _form,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          TextFormField(
            controller: _cur,
            obscureText: true,
            validator: req,
            decoration: AppDecor.input(hint: context.tr('curPass'), icon: Icons.lock_outline),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _new,
            obscureText: true,
            validator: (v) => (v == null || v.length < 8) ? context.tr('passShort') : null,
            decoration: AppDecor.input(hint: context.tr('newPass'), icon: Icons.lock_reset),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _confirm,
            obscureText: true,
            validator: (v) => v != _new.text ? context.tr('passMismatch') : null,
            decoration: AppDecor.input(hint: context.tr('confirmPass'), icon: Icons.lock_reset),
          ),
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
