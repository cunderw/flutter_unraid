import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_unraid/ui/widgets/cards/action_card.dart';

import '../../../helpers/pump_helpers.dart';

void main() {
  group('ActionCard', () {
    testWidgets('displays child content', (tester) async {
      await tester.pumpApp(const ActionCard(child: Text('Test Content')));

      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('displays title when provided', (tester) async {
      await tester.pumpApp(
        const ActionCard(title: 'Test Title', child: Text('Content')),
      );

      expect(find.text('Test Title'), findsOneWidget);
    });

    testWidgets('displays leading widget when provided', (tester) async {
      await tester.pumpApp(
        const ActionCard(
          title: 'Title',
          leading: Icon(Icons.star),
          child: Text('Content'),
        ),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('displays actions when provided', (tester) async {
      await tester.pumpApp(
        ActionCard(
          title: 'Title',
          actions: [
            TextButton(onPressed: () {}, child: const Text('Action 1')),
            TextButton(onPressed: () {}, child: const Text('Action 2')),
          ],
          child: const Text('Content'),
        ),
      );

      expect(find.text('Action 1'), findsOneWidget);
      expect(find.text('Action 2'), findsOneWidget);
    });

    testWidgets('renders in a Card', (tester) async {
      await tester.pumpApp(const ActionCard(child: Text('Content')));

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('is tappable when onTap is provided', (tester) async {
      var tapped = false;
      await tester.pumpApp(
        ActionCard(child: const Text('Content'), onTap: () => tapped = true),
      );

      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });

    testWidgets('does not display title when not provided', (tester) async {
      await tester.pumpApp(const ActionCard(child: Text('Content')));

      // Title should not render a Text widget for the title itself
      expect(find.text('Content'), findsOneWidget);
      expect(find.byType(Text), findsOneWidget); // Only the child
    });
  });
}
