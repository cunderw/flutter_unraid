import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_unraid/ui/screens/container_detail/container_status_section.dart';
import 'package:flutter_unraid/ui/widgets/data_display/status_badge.dart';

import '../../../helpers/factories.dart';
import '../../../helpers/pump_helpers.dart';

void main() {
  group('ContainerStatusSection', () {
    testWidgets('displays container icon', (tester) async {
      final container = makeRunningContainer();
      await tester.pumpApp(ContainerStatusSection(container: container));

      expect(find.byIcon(Icons.inventory_2), findsOneWidget);
    });

    testWidgets('displays container name', (tester) async {
      final container = makeRunningContainer();
      await tester.pumpApp(ContainerStatusSection(container: container));

      expect(find.text('test-container'), findsOneWidget);
    });

    testWidgets('displays container status text', (tester) async {
      final container = makeRunningContainer(status: 'Up 2 hours');
      await tester.pumpApp(ContainerStatusSection(container: container));

      expect(find.text('Up 2 hours'), findsOneWidget);
    });

    testWidgets('displays status badge', (tester) async {
      final container = makeRunningContainer();
      await tester.pumpApp(ContainerStatusSection(container: container));

      expect(find.byType(StatusBadge), findsOneWidget);
    });

    testWidgets('displays in a card', (tester) async {
      final container = makeRunningContainer();
      await tester.pumpApp(ContainerStatusSection(container: container));

      expect(find.byType(Card), findsOneWidget);
    });
  });
}
