import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_unraid/ui/widgets/cards/info_card.dart';

import '../../../helpers/pump_helpers.dart';

void main() {
  group('InfoCard', () {
    testWidgets('displays child content', (tester) async {
      await tester.pumpApp(
        const InfoCard(
          child: Text('Test Content'),
        ),
      );

      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('displays title when provided', (tester) async {
      await tester.pumpApp(
        const InfoCard(
          title: 'Test Title',
          child: Text('Content'),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
    });

    testWidgets('displays leading widget when provided', (tester) async {
      await tester.pumpApp(
        const InfoCard(
          title: 'Title',
          leading: Icon(Icons.info),
          child: Text('Content'),
        ),
      );

      expect(find.byIcon(Icons.info), findsOneWidget);
    });

    testWidgets('displays trailing widget when provided', (tester) async {
      await tester.pumpApp(
        const InfoCard(
          title: 'Title',
          trailing: Icon(Icons.arrow_forward),
          child: Text('Content'),
        ),
      );

      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    });

    testWidgets('renders in a Card', (tester) async {
      await tester.pumpApp(
        const InfoCard(
          child: Text('Content'),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('is tappable when onTap is provided', (tester) async {
      var tapped = false;
      await tester.pumpApp(
        InfoCard(
          child: const Text('Content'),
          onTap: () => tapped = true,
        ),
      );

      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });

    testWidgets('uses custom padding when provided', (tester) async {
      const customPadding = EdgeInsets.all(32);
      await tester.pumpApp(
        const InfoCard(
          padding: customPadding,
          child: Text('Content'),
        ),
      );

      final padding = tester.widget<Padding>(
        find.descendant(
          of: find.byType(InkWell),
          matching: find.byType(Padding),
        ).first,
      );
      expect(padding.padding, customPadding);
    });
  });
}
