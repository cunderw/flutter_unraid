import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_unraid/ui/widgets/layout/collapsible_section.dart';

import '../../../helpers/pump_helpers.dart';

void main() {
  group('CollapsibleSection', () {
    testWidgets('displays title in uppercase', (tester) async {
      await tester.pumpApp(
        CollapsibleSection(
          title: 'Overview',
          isExpanded: true,
          onToggle: () {},
          children: const [Text('Content')],
        ),
      );

      expect(find.text('OVERVIEW'), findsOneWidget);
    });

    testWidgets('shows expand_less icon when expanded', (tester) async {
      await tester.pumpApp(
        CollapsibleSection(
          title: 'Overview',
          isExpanded: true,
          onToggle: () {},
          children: const [Text('Content')],
        ),
      );

      expect(find.byIcon(Icons.expand_less), findsOneWidget);
    });

    testWidgets('shows expand_more icon when collapsed', (tester) async {
      await tester.pumpApp(
        CollapsibleSection(
          title: 'Overview',
          isExpanded: false,
          onToggle: () {},
          children: const [Text('Content')],
        ),
      );

      expect(find.byIcon(Icons.expand_more), findsOneWidget);
    });

    testWidgets('shows content when expanded', (tester) async {
      await tester.pumpApp(
        CollapsibleSection(
          title: 'Overview',
          isExpanded: true,
          onToggle: () {},
          children: const [Text('Content')],
        ),
      );

      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('hides content when collapsed', (tester) async {
      await tester.pumpApp(
        CollapsibleSection(
          title: 'Overview',
          isExpanded: false,
          onToggle: () {},
          children: const [Text('Content')],
        ),
      );

      expect(find.text('Content'), findsNothing);
    });

    testWidgets('calls onToggle when header is tapped', (tester) async {
      bool wasTapped = false;
      await tester.pumpApp(
        CollapsibleSection(
          title: 'Overview',
          isExpanded: true,
          onToggle: () {
            wasTapped = true;
          },
          children: const [Text('Content')],
        ),
      );

      await tester.tap(find.text('OVERVIEW'));
      expect(wasTapped, isTrue);
    });
  });
}
