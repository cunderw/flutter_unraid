import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_unraid/ui/widgets/feedback/inline_error.dart';

import '../../../helpers/pump_helpers.dart';

void main() {
  group('InlineError', () {
    testWidgets('displays error message', (tester) async {
      await tester.pumpApp(
        const InlineError(message: 'Something went wrong'),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('displays error icon', (tester) async {
      await tester.pumpApp(
        const InlineError(message: 'Error'),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('displays retry button when onRetry is provided', (tester) async {
      var retried = false;
      await tester.pumpApp(
        InlineError(
          message: 'Error',
          onRetry: () => retried = true,
        ),
      );

      final retryButton = find.byIcon(Icons.refresh);
      expect(retryButton, findsOneWidget);
      
      await tester.tap(retryButton);
      expect(retried, isTrue);
    });

    testWidgets('does not display retry button when onRetry is null', (tester) async {
      await tester.pumpApp(
        const InlineError(message: 'Error'),
      );

      expect(find.byIcon(Icons.refresh), findsNothing);
    });

    testWidgets('retry button has tooltip', (tester) async {
      await tester.pumpApp(
        InlineError(
          message: 'Error',
          onRetry: () {},
        ),
      );

      final iconButton = tester.widget<IconButton>(
        find.byType(IconButton),
      );
      expect(iconButton.tooltip, 'Retry');
    });

    testWidgets('takes full width', (tester) async {
      await tester.pumpApp(
        const InlineError(message: 'Error'),
      );

      final container = tester.widget<Container>(
        find.byType(Container),
      );
      expect(container.constraints?.maxWidth, double.infinity);
    });

    testWidgets('message text is expanded', (tester) async {
      await tester.pumpApp(
        const InlineError(message: 'Error'),
      );

      expect(find.byType(Expanded), findsOneWidget);
    });
  });
}
