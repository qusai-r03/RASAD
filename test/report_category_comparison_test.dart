import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:city_issue_reporter/features/complaints/widgets/report_category_comparison.dart';

void main() {
  Future<void> renderComparison(
    WidgetTester tester, {
    String? aiPrediction,
    String? citizenSelection,
    String? officialCategory,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReportCategoryComparison(
            aiPrediction: aiPrediction,
            citizenSelection: citizenSelection,
            officialCategory: officialCategory,
          ),
        ),
      ),
    );
  }

  testWidgets('Displays all three category labels', (tester) async {
    await renderComparison(tester);

    expect(find.text('AI Prediction'), findsOneWidget);
    expect(find.text('Citizen Selection'), findsOneWidget);
    expect(find.text('Official Category'), findsOneWidget);
  });

  testWidgets('Displays three different category values', (tester) async {
    await renderComparison(
      tester,
      aiPrediction: 'garbage',
      citizenSelection: 'pothole',
      officialCategory: 'water_leak',
    );

    expect(find.text('garbage'), findsOneWidget);
    expect(find.text('pothole'), findsOneWidget);
    expect(find.text('water_leak'), findsOneWidget);
    expect(find.text('Not available'), findsNothing);
  });

  testWidgets('Handles legacy reports with missing categories', (tester) async {
    await renderComparison(tester);

    expect(find.text('Not available'), findsNWidgets(3));
  });

  testWidgets('Handles partially available categories', (tester) async {
    await renderComparison(tester, citizenSelection: 'pothole');

    expect(find.text('pothole'), findsOneWidget);
    expect(find.text('Not available'), findsNWidgets(2));
  });

  testWidgets('Handles empty and whitespace category values', (tester) async {
    await renderComparison(
      tester,
      aiPrediction: '',
      citizenSelection: '   ',
      officialCategory: null,
    );

    expect(find.text('Not available'), findsNWidgets(3));
  });

  testWidgets('Handles identical category values', (tester) async {
    await renderComparison(
      tester,
      aiPrediction: 'pothole',
      citizenSelection: 'pothole',
      officialCategory: 'pothole',
    );

    expect(find.text('pothole'), findsNWidgets(3));
    expect(find.text('Not available'), findsNothing);
  });
}
