import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/mock/mock_data.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_image.dart';
import '../../shared/widgets/rasd_logo.dart';
import 'current_user_provider.dart';

/// ⚠️ شاشة دخول بالتصميم المعتمد لكن بدون Auth حقيقي: أي بيانات = حساب الموظف الوهمي.
/// عضو الـ Auth يستبدل onPressed بالتحقق الفعلي، ويحذف زر الدخول التجريبي (DEV).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _id = TextEditingController();
  final _pass = TextEditingController();
  bool _hide = true;

  @override
  void dispose() {
    _id.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(fit: StackFit.expand, children: [
        const AppImage(
          asset: AppAssets.loginBg,
          fallback: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0E2A1D), Color(0xFF0B1A14)],
              ),
            ),
          ),
        ),
        Container(color: Colors.black.withValues(alpha: .35)),
        SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const RasdLogo(size: 64, light: true),
                const SizedBox(height: 10),
                Text(context.tr('appSubtitle'), style: const TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
                  child: Column(children: [
                    TextField(
                      controller: _id,
                      keyboardType: TextInputType.number,
                      decoration: AppDecor.input(hint: context.tr('nationalId'), icon: Icons.person_outline),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _pass,
                      obscureText: _hide,
                      decoration: AppDecor.input(
                        hint: context.tr('password'),
                        icon: Icons.lock_outline,
                        suffix: IconButton(
                          onPressed: () => setState(() => _hide = !_hide),
                          icon: Icon(_hide ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppColors.muted),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      // TODO(Auth): استبدل بتسجيل الدخول الحقيقي
                      onPressed: () => ref.read(currentUserProvider.notifier).state = mockEmployee,
                      child: Text(context.tr('login')),
                    ),
                  ]),
                ),
                const SizedBox(height: 12),
                TextButton(
                  // DEV فقط: لتجربة واجهة المواطن. يُحذف مع الـ Auth الحقيقي.
                  onPressed: () => ref.read(currentUserProvider.notifier).state = mockCitizen,
                  child: Text(context.tr('devCitizen'), style: const TextStyle(color: Colors.white70)),
                ),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}
