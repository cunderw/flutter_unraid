import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_unraid/ui/screens/container_detail/container_status_section.dart';
import 'package:flutter_unraid/ui/widgets/data_display/container_icon.dart';
import 'package:flutter_unraid/ui/widgets/data_display/status_badge.dart';

import '../../../helpers/factories.dart';
import '../../../helpers/pump_helpers.dart';

void main() {
  group('ContainerStatusSection', () {
    testWidgets('displays container icon', (tester) async {
      final container = makeRunningContainer();
      await tester.pumpApp(ContainerStatusSection(container: container));
      await tester.pumpAndSettle();

      expect(find.byType(ContainerIcon), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('displays fallback icon when no iconUrl', (tester) async {
      final container = makeRunningContainer();
      await tester.pumpApp(ContainerStatusSection(container: container));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.inventory_2), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('displays container name', (tester) async {
      final container = makeRunningContainer();
      await tester.pumpApp(ContainerStatusSection(container: container));
      await tester.pumpAndSettle();

      expect(find.text('test-container'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('displays container status text', (tester) async {
      final container = makeDockerContainer(
        state: "RUNNING",
        status: 'Up 2 hours',
      );
      await tester.pumpApp(ContainerStatusSection(container: container));
      await tester.pumpAndSettle();

      expect(find.text('Up 2 hours'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('displays status badge', (tester) async {
      final container = makeRunningContainer();
      await tester.pumpApp(ContainerStatusSection(container: container));
      await tester.pumpAndSettle();

      expect(find.byType(StatusBadge), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('displays in a card', (tester) async {
      final container = makeRunningContainer();
      await tester.pumpApp(ContainerStatusSection(container: container));
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsOneWidget);
      await tester.pumpAndSettle();
    });
  });
}
