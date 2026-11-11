import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/l10n/app_strings.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() => runApp(const ProviderScope(child: RasdApp()));

class RasdApp extends ConsumerWidget {
  const RasdApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'RASD',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      locale: ref.watch(localeProvider),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: ref.watch(routerProvider),
    );
  }
}
