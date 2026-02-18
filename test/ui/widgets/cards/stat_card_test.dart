import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_unraid/ui/widgets/cards/stat_card.dart';

import '../../../helpers/pump_helpers.dart';

void main() {
  group('StatCard', () {
    testWidgets('displays label', (tester) async {
      await tester.pumpApp(
        const StatCard(
          label: 'Uptime',
          value: '2 days',
        ),
      );

      expect(find.text('Uptime'), findsOneWidget);
    });

    testWidgets('displays value', (tester) async {
      await tester.pumpApp(
        const StatCard(
          label: 'Uptime',
          value: '2 days',
        ),
      );

      expect(find.text('2 days'), findsOneWidget);
    });

    testWidgets('displays icon when provided', (tester) async {
      await tester.pumpApp(
        const StatCard(
          label: 'Memory',
          value: '50%',
          icon: Icons.memory,
        ),
      );

      expect(find.byIcon(Icons.memory), findsOneWidget);
    });

    testWidgets('displays trailing widget when provided', (tester) async {
      await tester.pumpApp(
        const StatCard(
          label: 'CPU',
          value: '25%',
          trailing: Icon(Icons.trending_up),
        ),
      );

      expect(find.byIcon(Icons.trending_up), findsOneWidget);
    });

    testWidgets('renders in a Card', (tester) async {
      await tester.pumpApp(
        const StatCard(
          label: 'Test',
          value: '100',
        ),
      );

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('does not display icon when not provided', (tester) async {
      await tester.pumpApp(
        const StatCard(
          label: 'Test',
          value: '100',
        ),
      );

      expect(find.byType(Icon), findsNothing);
    });
  });
}
