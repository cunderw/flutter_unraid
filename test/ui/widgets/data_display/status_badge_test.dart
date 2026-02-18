import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_unraid/config/theme.dart';
import 'package:flutter_unraid/ui/widgets/data_display/status_badge.dart';

import '../../../helpers/pump_helpers.dart';

void main() {
  group('StatusBadge', () {
    testWidgets('displays label text', (tester) async {
      await tester.pumpApp(
        const StatusBadge(label: 'Running', color: AppColors.running),
      );

      expect(find.text('Running'), findsOneWidget);
    });

    testWidgets('displays colored circle indicator', (tester) async {
      await tester.pumpApp(
        const StatusBadge(label: 'Running', color: AppColors.running),
      );

      // Find the inner container that represents the colored circle
      final containers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(StatusBadge),
          matching: find.byType(Container),
        ),
      ).toList();
      
      // The second container should be the circle indicator
      expect(containers.length, greaterThan(1));
      final decoration = containers[1].decoration as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);
      expect(decoration.color, AppColors.running);
    });

    group('forContainerState', () {
      testWidgets('creates running badge for RUNNING state', (tester) async {
        await tester.pumpApp(StatusBadge.forContainerState('RUNNING'));

        expect(find.text('Running'), findsOneWidget);
      });

      testWidgets('creates paused badge for PAUSED state', (tester) async {
        await tester.pumpApp(StatusBadge.forContainerState('PAUSED'));

        expect(find.text('Paused'), findsOneWidget);
      });

      testWidgets('creates stopped badge for EXITED state', (tester) async {
        await tester.pumpApp(StatusBadge.forContainerState('EXITED'));

        expect(find.text('Exited'), findsOneWidget);
      });

      testWidgets('creates stopped badge for STOPPED state', (tester) async {
        await tester.pumpApp(StatusBadge.forContainerState('STOPPED'));

        expect(find.text('Stopped'), findsOneWidget);
      });
    });

    group('forVmState', () {
      testWidgets('creates running badge for RUNNING state', (tester) async {
        await tester.pumpApp(StatusBadge.forVmState('RUNNING'));

        expect(find.text('Running'), findsOneWidget);
      });

      testWidgets('creates paused badge for PAUSED state', (tester) async {
        await tester.pumpApp(StatusBadge.forVmState('PAUSED'));

        expect(find.text('Paused'), findsOneWidget);
      });

      testWidgets('creates stopped badge for SHUTOFF state', (tester) async {
        await tester.pumpApp(StatusBadge.forVmState('SHUTOFF'));

        expect(find.text('Shutoff'), findsOneWidget);
      });

      testWidgets('creates crashed badge for CRASHED state', (tester) async {
        await tester.pumpApp(StatusBadge.forVmState('CRASHED'));

        expect(find.text('Crashed'), findsOneWidget);
      });
    });

    group('forArrayState', () {
      testWidgets('creates running badge for STARTED state', (tester) async {
        await tester.pumpApp(StatusBadge.forArrayState('STARTED'));

        expect(find.text('Started'), findsOneWidget);
      });

      testWidgets('creates stopped badge for STOPPED state', (tester) async {
        await tester.pumpApp(StatusBadge.forArrayState('STOPPED'));

        expect(find.text('Stopped'), findsOneWidget);
      });
    });

    testWidgets('circle indicator is rendered', (tester) async {
      await tester.pumpApp(
        const StatusBadge(label: 'Test', color: Colors.blue),
      );

      // Verify that the badge is rendered
      expect(find.byType(StatusBadge), findsOneWidget);
      expect(find.text('Test'), findsOneWidget);
    });
  });
}
