import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_unraid/blocs/system/system_state.dart';
import 'package:flutter_unraid/ui/screens/home/tabs/main_tab.dart';
import 'package:flutter_unraid/ui/widgets/cards/stat_card.dart';
import 'package:flutter_unraid/ui/widgets/feedback/error_display.dart';
import 'package:flutter_unraid/ui/widgets/feedback/loading_indicator.dart';

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

      expect(find.byType(LoadingIndicator), findsOneWidget);
      expect(find.text('Loading system info...'), findsOneWidget);
    });

    testWidgets('displays loading indicator when SystemLoading', (tester) async {
      await tester.pumpAppWithBlocs(
        const MainTab(),
        systemCubit: mockSystemCubit,
        systemState: const SystemLoading(),
      );

      expect(find.byType(LoadingIndicator), findsOneWidget);
    });

    testWidgets('displays error display when SystemError', (tester) async {
      await tester.pumpAppWithBlocs(
        const MainTab(),
        systemCubit: mockSystemCubit,
        systemState: const SystemError('Failed to load system info'),
      );

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

      expect(find.text('Overview'), findsOneWidget);
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

      expect(find.text('Uptime'), findsOneWidget);
      expect(find.text('Memory'), findsOneWidget);
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

      expect(find.text('System Information'), findsOneWidget);
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

      expect(find.text('Array Status'), findsOneWidget);
    });
  });
}
