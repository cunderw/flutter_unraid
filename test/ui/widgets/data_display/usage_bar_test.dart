import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_unraid/ui/widgets/data_display/usage_bar.dart';

import '../../../helpers/pump_helpers.dart';

void main() {
  group('UsageBar', () {
    testWidgets('displays progress bar', (tester) async {
      await tester.pumpApp(
        const UsageBar(percentage: 0.5),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('displays label when provided', (tester) async {
      await tester.pumpApp(
        const UsageBar(
          percentage: 0.5,
          label: 'Memory',
        ),
      );

      expect(find.text('Memory'), findsOneWidget);
    });

    testWidgets('displays detail when provided', (tester) async {
      await tester.pumpApp(
        const UsageBar(
          percentage: 0.5,
          detail: '50%',
        ),
      );

      expect(find.text('50%'), findsOneWidget);
    });

    testWidgets('displays both label and detail', (tester) async {
      await tester.pumpApp(
        const UsageBar(
          percentage: 0.75,
          label: 'CPU',
          detail: '75%',
        ),
      );

      expect(find.text('CPU'), findsOneWidget);
      expect(find.text('75%'), findsOneWidget);
    });

    testWidgets('clamps percentage between 0 and 1', (tester) async {
      await tester.pumpApp(
        const UsageBar(percentage: 1.5),
      );

      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progressIndicator.value, 1.0);
    });

    testWidgets('clamps negative percentage to 0', (tester) async {
      await tester.pumpApp(
        const UsageBar(percentage: -0.5),
      );

      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progressIndicator.value, 0.0);
    });

    testWidgets('uses custom height when provided', (tester) async {
      await tester.pumpApp(
        const UsageBar(
          percentage: 0.5,
          height: 16,
        ),
      );

      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progressIndicator.minHeight, 16);
    });

    testWidgets('uses default height of 8', (tester) async {
      await tester.pumpApp(
        const UsageBar(percentage: 0.5),
      );

      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progressIndicator.minHeight, 8);
    });
  });
}
