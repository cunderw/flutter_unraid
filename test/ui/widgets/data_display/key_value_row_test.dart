import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_unraid/ui/widgets/data_display/key_value_row.dart';

import '../../../helpers/pump_helpers.dart';

void main() {
  group('KeyValueRow', () {
    testWidgets('displays label', (tester) async {
      await tester.pumpApp(
        const KeyValueRow(
          label: 'Name',
          value: 'John Doe',
        ),
      );

      expect(find.text('Name'), findsOneWidget);
    });

    testWidgets('displays value', (tester) async {
      await tester.pumpApp(
        const KeyValueRow(
          label: 'Name',
          value: 'John Doe',
        ),
      );

      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('displays empty value when not provided', (tester) async {
      await tester.pumpApp(
        const KeyValueRow(
          label: 'Empty',
        ),
      );

      expect(find.text('Empty'), findsOneWidget);
    });

    testWidgets('uses valueWidget when provided', (tester) async {
      await tester.pumpApp(
        const KeyValueRow(
          label: 'Status',
          valueWidget: Icon(Icons.check_circle),
        ),
      );

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('prefers valueWidget over value string', (tester) async {
      await tester.pumpApp(
        const KeyValueRow(
          label: 'Field',
          value: 'Text Value',
          valueWidget: Icon(Icons.star),
        ),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.text('Text Value'), findsNothing);
    });

    testWidgets('label has fixed width', (tester) async {
      await tester.pumpApp(
        const KeyValueRow(
          label: 'Label',
          value: 'Value',
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(KeyValueRow),
          matching: find.byType(SizedBox),
        ),
      );
      expect(sizedBox.width, 120);
    });

    testWidgets('value text has ellipsis overflow', (tester) async {
      await tester.pumpApp(
        const KeyValueRow(
          label: 'Long',
          value: 'Very long value that should be truncated',
        ),
      );

      final textWidget = tester.widget<Text>(
        find.text('Very long value that should be truncated'),
      );
      expect(textWidget.overflow, TextOverflow.ellipsis);
      expect(textWidget.maxLines, 1);
    });
  });
}
