import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rasd/core/mock/mock_data.dart';
import 'package:rasd/features/auth/current_user_provider.dart';
import 'package:rasd/features/home/citizen_home_screen.dart';
import 'package:rasd/features/home/employee_home_screen.dart';

Widget _wrap(Widget home, {required Override user}) => ProviderScope(
      overrides: [user],
      child: MaterialApp(
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: home,
      ),
    );

void main() {
  testWidgets('Employee home greets the employee', (tester) async {
    await tester.pumpWidget(_wrap(
      const EmployeeHomeScreen(),
      user: currentUserProvider.overrideWith((ref) => mockEmployee),
    ));
    expect(find.textContaining(mockEmployee.firstName), findsOneWidget);
  });

  testWidgets('Citizen home greets the citizen', (tester) async {
    await tester.pumpWidget(_wrap(
      const CitizenHomeScreen(),
      user: currentUserProvider.overrideWith((ref) => mockCitizen),
    ));
    expect(find.textContaining(mockCitizen.firstName), findsOneWidget);
  });
}
