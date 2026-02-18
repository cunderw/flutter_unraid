import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_unraid/ui/widgets/layout/section_header.dart';

import '../../../helpers/pump_helpers.dart';

void main() {
  group('SectionHeader', () {
    testWidgets('displays title in uppercase', (tester) async {
      await tester.pumpApp(
        const SectionHeader(title: 'settings'),
      );

      expect(find.text('SETTINGS'), findsOneWidget);
    });

    testWidgets('displays trailing widget when provided', (tester) async {
      await tester.pumpApp(
        const SectionHeader(
          title: 'Info',
          trailing: Icon(Icons.info),
        ),
      );

      expect(find.byIcon(Icons.info), findsOneWidget);
    });

    testWidgets('does not display trailing when not provided', (tester) async {
      await tester.pumpApp(
        const SectionHeader(title: 'Title'),
      );

      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('uses Row layout', (tester) async {
      await tester.pumpApp(
        const SectionHeader(title: 'Title'),
      );

      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets('has default padding', (tester) async {
      await tester.pumpApp(
        const SectionHeader(title: 'Title'),
      );

      final padding = tester.widget<Padding>(
        find.byType(Padding),
      );
      expect(padding.padding, isNotNull);
    });

    testWidgets('accepts custom padding', (tester) async {
      const customPadding = EdgeInsets.all(32);
      await tester.pumpApp(
        const SectionHeader(
          title: 'Title',
          padding: customPadding,
        ),
      );

      final padding = tester.widget<Padding>(
        find.byType(Padding),
      );
      expect(padding.padding, customPadding);
    });

    testWidgets('trailing is on the right side', (tester) async {
      await tester.pumpApp(
        const SectionHeader(
          title: 'Title',
          trailing: Text('Right'),
        ),
      );

      final row = tester.widget<Row>(find.byType(Row));
      expect(row.children.length, 3); // Title, Spacer, Trailing
      expect(find.byType(Spacer), findsOneWidget);
    });
  });
}
