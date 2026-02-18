import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_unraid/blocs/vms/vm_state.dart';
import 'package:flutter_unraid/ui/screens/home/tabs/vms_tab.dart';
import 'package:flutter_unraid/ui/widgets/feedback/empty_state.dart';
import 'package:flutter_unraid/ui/widgets/feedback/error_display.dart';
import 'package:flutter_unraid/ui/widgets/feedback/loading_indicator.dart';

import '../../../../helpers/factories.dart';
import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_helpers.dart';

void main() {
  late MockVmCubit mockVmCubit;

  setUp(() {
    mockVmCubit = MockVmCubit();
  });

  group('VmsTab', () {
    testWidgets('displays loading indicator when VmInitial', (tester) async {
      await tester.pumpAppWithBlocs(
        const VmsTab(),
        vmCubit: mockVmCubit,
        vmState: const VmInitial(),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LoadingIndicator), findsOneWidget);
      expect(find.text('Loading virtual machines...'), findsOneWidget);
    });

    testWidgets('displays loading indicator when VmLoading', (tester) async {
      await tester.pumpAppWithBlocs(
        const VmsTab(),
        vmCubit: mockVmCubit,
        vmState: const VmLoading(),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LoadingIndicator), findsOneWidget);
    });

    testWidgets('displays error display when VmError', (tester) async {
      await tester.pumpAppWithBlocs(
        const VmsTab(),
        vmCubit: mockVmCubit,
        vmState: const VmError('Failed to load VMs'),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ErrorDisplay), findsOneWidget);
      expect(find.text('Failed to load VMs'), findsOneWidget);
    });

    testWidgets('displays empty state when no VMs', (tester) async {
      await tester.pumpAppWithBlocs(
        const VmsTab(),
        vmCubit: mockVmCubit,
        vmState: const VmLoaded([]),
      );
      await tester.pumpAndSettle();

      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('No virtual machines found.'), findsOneWidget);
      expect(find.byIcon(Icons.computer_outlined), findsOneWidget);
    });

    testWidgets('displays VMs when VmLoaded with data', (tester) async {
      final vms = [
        makeRunningVm(id: 'vm1'),
        makeStoppedVm(id: 'vm2'),
      ];

      await tester.pumpAppWithBlocs(
        const VmsTab(),
        vmCubit: mockVmCubit,
        vmState: VmLoaded(vms),
      );
      await tester.pumpAndSettle();

      expect(find.text('Virtual Machines'), findsOneWidget);
      expect(find.text('1 running / 2 total'), findsOneWidget);
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('displays VM tiles with status badges', (tester) async {
      final vms = [
        makeRunningVm(id: 'vm1'),
        makeStoppedVm(id: 'vm2'),
      ];

      await tester.pumpAppWithBlocs(
        const VmsTab(),
        vmCubit: mockVmCubit,
        vmState: VmLoaded(vms),
      );
      await tester.pumpAndSettle();

      // Should display VM names
      expect(find.text('TestVM'), findsNWidgets(2));
    });

    testWidgets('displays computer icon for VMs', (tester) async {
      final vms = [makeRunningVm()];

      await tester.pumpAppWithBlocs(
        const VmsTab(),
        vmCubit: mockVmCubit,
        vmState: VmLoaded(vms),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.computer), findsOneWidget);
    });
  });
}
