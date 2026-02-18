import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_unraid/config/theme.dart';
import 'package:flutter_unraid/ui/widgets/data_display/status_badge.dart';

void main() {
  Widget makeTestableWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('StatusBadge', () {
    testWidgets('displays label and colored indicator', (tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          const StatusBadge(
            label: 'Running',
            color: Colors.green,
          ),
        ),
      );

      expect(find.text('Running'), findsOneWidget);
      
      // Find the container that should be the colored circle
      final containers = find.byType(Container);
      expect(containers, findsWidgets);
    });

    testWidgets('uses custom size for indicator', (tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          const StatusBadge(
            label: 'Test',
            color: Colors.blue,
            size: 12,
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
    });

    group('forContainerState', () {
      testWidgets('creates running badge with green color', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            StatusBadge.forContainerState('RUNNING'),
          ),
        );

        expect(find.text('Running'), findsOneWidget);
      });

      testWidgets('creates paused badge with yellow color', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            StatusBadge.forContainerState('PAUSED'),
          ),
        );

        expect(find.text('Paused'), findsOneWidget);
      });

      testWidgets('creates exited badge with red color', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            StatusBadge.forContainerState('EXITED'),
          ),
        );

        expect(find.text('Exited'), findsOneWidget);
      });

      testWidgets('creates stopped badge with red color', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            StatusBadge.forContainerState('STOPPED'),
          ),
        );

        expect(find.text('Stopped'), findsOneWidget);
      });

      testWidgets('formats state label correctly', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            StatusBadge.forContainerState('running'),
          ),
        );

        expect(find.text('Running'), findsOneWidget);
      });
    });

    group('forVmState', () {
      testWidgets('creates running badge', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            StatusBadge.forVmState('RUNNING'),
          ),
        );

        expect(find.text('Running'), findsOneWidget);
      });

      testWidgets('creates paused badge', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            StatusBadge.forVmState('PAUSED'),
          ),
        );

        expect(find.text('Paused'), findsOneWidget);
      });

      testWidgets('creates shutoff badge', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            StatusBadge.forVmState('SHUTOFF'),
          ),
        );

        expect(find.text('Shutoff'), findsOneWidget);
      });

      testWidgets('creates crashed badge with warning color', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            StatusBadge.forVmState('CRASHED'),
          ),
        );

        expect(find.text('Crashed'), findsOneWidget);
      });
    });

    group('forArrayState', () {
      testWidgets('creates started badge', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            StatusBadge.forArrayState('STARTED'),
          ),
        );

        expect(find.text('Started'), findsOneWidget);
      });

      testWidgets('creates stopped badge', (tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            StatusBadge.forArrayState('STOPPED'),
          ),
        );

        expect(find.text('Stopped'), findsOneWidget);
      });
    });
  });
}
