import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_unraid/ui/widgets/data_display/key_value_row.dart';

void main() {
  Widget makeTestableWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('KeyValueRow', () {
    testWidgets('displays label and value', (tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          const KeyValueRow(
            label: 'Test Label',
            value: 'Test Value',
          ),
        ),
      );

      expect(find.text('Test Label'), findsOneWidget);
      expect(find.text('Test Value'), findsOneWidget);
    });

    testWidgets('displays label with empty value by default', (tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          const KeyValueRow(
            label: 'Test Label',
          ),
        ),
      );

      expect(find.text('Test Label'), findsOneWidget);
      expect(find.text(''), findsOneWidget);
    });

    testWidgets('displays custom widget instead of value text when provided',
        (tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          const KeyValueRow(
            label: 'Test Label',
            value: 'This should not appear',
            valueWidget: Icon(Icons.check),
          ),
        ),
      );

      expect(find.text('Test Label'), findsOneWidget);
      expect(find.text('This should not appear'), findsNothing);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('applies custom label style when provided', (tester) async {
      const customStyle = TextStyle(
        fontSize: 20,
        color: Colors.red,
        fontWeight: FontWeight.bold,
      );

      await tester.pumpWidget(
        makeTestableWidget(
          const KeyValueRow(
            label: 'Test Label',
            value: 'Test Value',
            labelStyle: customStyle,
          ),
        ),
      );

      final labelText = tester.widget<Text>(find.text('Test Label'));
      expect(labelText.style?.fontSize, customStyle.fontSize);
      expect(labelText.style?.color, customStyle.color);
      expect(labelText.style?.fontWeight, customStyle.fontWeight);
    });

    testWidgets('applies custom value style when provided', (tester) async {
      const customStyle = TextStyle(
        fontSize: 18,
        color: Colors.blue,
        fontWeight: FontWeight.w500,
      );

      await tester.pumpWidget(
        makeTestableWidget(
          const KeyValueRow(
            label: 'Test Label',
            value: 'Test Value',
            valueStyle: customStyle,
          ),
        ),
      );

      final valueText = tester.widget<Text>(find.text('Test Value'));
      expect(valueText.style?.fontSize, customStyle.fontSize);
      expect(valueText.style?.color, customStyle.color);
      expect(valueText.style?.fontWeight, customStyle.fontWeight);
    });

    testWidgets('label is constrained to fixed width', (tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          const KeyValueRow(
            label: 'Very Long Label That Should Be Constrained',
            value: 'Value',
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.text('Very Long Label That Should Be Constrained'),
          matching: find.byType(SizedBox),
        ),
      );
      expect(sizedBox.width, 120);
    });

    testWidgets('value expands to fill remaining space', (tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          const KeyValueRow(
            label: 'Label',
            value: 'Very long value that should expand to fill the remaining space',
          ),
        ),
      );

      expect(
        find.ancestor(
          of: find.text('Very long value that should expand to fill the remaining space'),
          matching: find.byType(Expanded),
        ),
        findsOneWidget,
      );
    });
  });
}
