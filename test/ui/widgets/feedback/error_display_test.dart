import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_unraid/ui/widgets/feedback/error_display.dart';

import '../../../helpers/pump_helpers.dart';

void main() {
  group('ErrorDisplay', () {
    testWidgets('displays error message', (tester) async {
      await tester.pumpApp(const ErrorDisplay(message: 'Something went wrong'));

      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('displays default error icon', (tester) async {
      await tester.pumpApp(const ErrorDisplay(message: 'Error'));

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('displays custom icon when provided', (tester) async {
      await tester.pumpApp(
        const ErrorDisplay(message: 'Error', icon: Icons.warning),
      );

      expect(find.byIcon(Icons.warning), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsNothing);
    });

    testWidgets('displays retry button when onRetry is provided', (
      tester,
    ) async {
      var retried = false;
      await tester.pumpApp(
        ErrorDisplay(message: 'Error', onRetry: () => retried = true),
      );

      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      expect(retried, isTrue);
    });

    testWidgets('does not display retry button when onRetry is null', (
      tester,
    ) async {
      await tester.pumpApp(const ErrorDisplay(message: 'Error'));

      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('is centered', (tester) async {
      await tester.pumpApp(const ErrorDisplay(message: 'Error'));

      expect(
        find.descendant(
          of: find.byType(ErrorDisplay),
          matching: find.byType(Center),
        ),
        findsAtLeast(1),
      );
    });

    testWidgets('message is center-aligned', (tester) async {
      await tester.pumpApp(const ErrorDisplay(message: 'Error'));

      final textWidget = tester.widget<Text>(find.text('Error'));
      expect(textWidget.textAlign, TextAlign.center);
    });
  });
}
