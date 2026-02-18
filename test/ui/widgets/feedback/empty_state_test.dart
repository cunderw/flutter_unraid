import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_unraid/ui/widgets/feedback/empty_state.dart';

import '../../../helpers/pump_helpers.dart';

void main() {
  group('EmptyState', () {
    testWidgets('displays message text', (tester) async {
      await tester.pumpApp(const EmptyState(message: 'No items found'));

      expect(find.text('No items found'), findsOneWidget);
    });

    testWidgets('displays default inbox icon when not specified', (tester) async {
      await tester.pumpApp(const EmptyState(message: 'No items'));

      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('displays custom icon when provided', (tester) async {
      await tester.pumpApp(
        const EmptyState(message: 'No data', icon: Icons.error_outline),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsNothing);
    });

    testWidgets('displays action widget when provided', (tester) async {
      await tester.pumpApp(
        EmptyState(
          message: 'No items',
          action: ElevatedButton(
            onPressed: () {},
            child: const Text('Add Item'),
          ),
        ),
      );

      expect(find.text('Add Item'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('does not display action when not provided', (tester) async {
      await tester.pumpApp(const EmptyState(message: 'No items'));

      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('is centered', (tester) async {
      await tester.pumpApp(const EmptyState(message: 'No items'));

      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('message is center-aligned', (tester) async {
      await tester.pumpApp(const EmptyState(message: 'No items'));

      final textWidget = tester.widget<Text>(find.text('No items'));
      expect(textWidget.textAlign, TextAlign.center);
    });
  });
}
