import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_unraid/blocs/system/system_state.dart';
import 'package:flutter_unraid/ui/screens/home/tabs/main_tab.dart';
import 'package:flutter_unraid/ui/widgets/cards/stat_card.dart';
import 'package:flutter_unraid/ui/widgets/feedback/error_display.dart';
import 'package:flutter_unraid/ui/widgets/feedback/loading_indicator.dart';
import 'package:flutter_unraid/ui/widgets/layout/collapsible_section.dart';

import '../../../../helpers/factories.dart';
import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_helpers.dart';

void main() {
  late MockSystemCubit mockSystemCubit;

  setUp(() {
    mockSystemCubit = MockSystemCubit();
  });

  group('MainTab', () {
    testWidgets('displays loading indicator when SystemInitial', (tester) async {
      await tester.pumpAppWithBlocs(
        const MainTab(),
        systemCubit: mockSystemCubit,
        systemState: const SystemInitial(),
      );
      await tester.pump();

      expect(find.byType(LoadingIndicator), findsOneWidget);
      expect(find.text('Loading system info...'), findsOneWidget);
    });

    testWidgets('displays loading indicator when SystemLoading', (tester) async {
      await tester.pumpAppWithBlocs(
        const MainTab(),
        systemCubit: mockSystemCubit,
        systemState: const SystemLoading(),
      );
      await tester.pump();

      expect(find.byType(LoadingIndicator), findsOneWidget);
    });

    testWidgets('displays error display when SystemError', (tester) async {
      await tester.pumpAppWithBlocs(
        const MainTab(),
        systemCubit: mockSystemCubit,
        systemState: const SystemError('Failed to load system info'),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ErrorDisplay), findsOneWidget);
      expect(find.text('Failed to load system info'), findsOneWidget);
    });

    testWidgets('displays system info when SystemLoaded', (tester) async {
      await tester.pumpAppWithBlocs(
        const MainTab(),
        systemCubit: mockSystemCubit,
        systemState: SystemLoaded(
          systemInfo: makeSystemInfo(),
          memory: makeMemoryUtilization(),
          arrayData: makeArrayData(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('OVERVIEW'), findsOneWidget);
      expect(find.byType(StatCard), findsWidgets);
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('displays uptime and memory stat cards', (tester) async {
      await tester.pumpAppWithBlocs(
        const MainTab(),
        systemCubit: mockSystemCubit,
        systemState: SystemLoaded(
          systemInfo: makeSystemInfo(),
          memory: makeMemoryUtilization(percentTotal: 45.5),
          arrayData: makeArrayData(),
        ),
      );
      await tester.pumpAndSettle();

      // "Uptime" appears in both StatCard and KeyValueRow; "Memory" in StatCard and InfoCard
      expect(find.text('Uptime'), findsNWidgets(2));
      expect(find.text('Memory'), findsNWidgets(2));
      expect(find.text('45.5%'), findsOneWidget);
    });

    testWidgets('displays system information section', (tester) async {
      await tester.pumpAppWithBlocs(
        const MainTab(),
        systemCubit: mockSystemCubit,
        systemState: SystemLoaded(
          systemInfo: makeSystemInfo(),
          memory: makeMemoryUtilization(),
          arrayData: makeArrayData(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('SYSTEM'), findsOneWidget);
    });

    testWidgets('displays array status section', (tester) async {
      await tester.pumpAppWithBlocs(
        const MainTab(),
        systemCubit: mockSystemCubit,
        systemState: SystemLoaded(
          systemInfo: makeSystemInfo(),
          memory: makeMemoryUtilization(),
          arrayData: makeArrayData(state: 'STARTED'),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('ARRAY'), 200);
      expect(find.text('ARRAY'), findsOneWidget);
    });

    testWidgets('has collapsible sections', (tester) async {
      await tester.pumpAppWithBlocs(
        const MainTab(),
        systemCubit: mockSystemCubit,
        systemState: SystemLoaded(
          systemInfo: makeSystemInfo(),
          memory: makeMemoryUtilization(),
          arrayData: makeArrayData(),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll to see all sections
      await tester.scrollUntilVisible(find.text('DISKS'), 200);

      expect(find.byType(CollapsibleSection), findsNWidgets(4));
    });

    testWidgets('Overview and System sections are expanded by default',
        (tester) async {
      await tester.pumpAppWithBlocs(
        const MainTab(),
        systemCubit: mockSystemCubit,
        systemState: SystemLoaded(
          systemInfo: makeSystemInfo(),
          memory: makeMemoryUtilization(),
          arrayData: makeArrayData(),
        ),
      );
      await tester.pumpAndSettle();

      // Overview is expanded - stat cards should be visible
      expect(find.byType(StatCard), findsWidgets);

      // System is expanded - server info should be visible
      expect(find.text('Server Info'), findsOneWidget);
    });

    testWidgets('Array and Disks sections are collapsed by default',
        (tester) async {
      await tester.pumpAppWithBlocs(
        const MainTab(),
        systemCubit: mockSystemCubit,
        systemState: SystemLoaded(
          systemInfo: makeSystemInfo(),
          memory: makeMemoryUtilization(),
          arrayData: makeArrayData(),
        ),
      );
      await tester.pumpAndSettle();

      // Array section header is visible (scroll to it)
      await tester.scrollUntilVisible(find.text('ARRAY'), 200);
      expect(find.text('ARRAY'), findsOneWidget);
      // But Array Status card should not be visible (collapsed)
      expect(find.text('Array Status'), findsNothing);
    });

    testWidgets('can expand and collapse sections', (tester) async {
      await tester.pumpAppWithBlocs(
        const MainTab(),
        systemCubit: mockSystemCubit,
        systemState: SystemLoaded(
          systemInfo: makeSystemInfo(),
          memory: makeMemoryUtilization(),
          arrayData: makeArrayData(),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll to Array section
      await tester.scrollUntilVisible(find.text('ARRAY'), 200);

      // Array section is collapsed
      expect(find.text('Array Status'), findsNothing);

      // Tap to expand
      await tester.tap(find.text('ARRAY'));
      await tester.pumpAndSettle();

      // Now Array Status should be visible
      expect(find.text('Array Status'), findsOneWidget);

      // Tap again to collapse
      await tester.tap(find.text('ARRAY'));
      await tester.pumpAndSettle();

      // Array Status should be hidden again
      expect(find.text('Array Status'), findsNothing);
    });
  });
}
