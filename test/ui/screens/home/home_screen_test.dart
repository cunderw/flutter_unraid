import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_unraid/data/models/docker_container.dart';
import 'package:flutter_unraid/data/models/share.dart';
import 'package:flutter_unraid/data/models/vm_domain.dart';
import 'package:flutter_unraid/ui/screens/home/home_screen.dart';

import '../../../helpers/factories.dart';
import '../../../helpers/get_it_helpers.dart';
import '../../../helpers/mocks.dart';
import '../../../helpers/pump_helpers.dart';

void main() {
  late MockSystemRepository mockSystemRepo;
  late MockDockerRepository mockDockerRepo;
  late MockVmRepository mockVmRepo;
  late MockShareRepository mockShareRepo;

  setUp(() async {
    mockSystemRepo = MockSystemRepository();
    mockDockerRepo = MockDockerRepository();
    mockVmRepo = MockVmRepository();
    mockShareRepo = MockShareRepository();

    // Stub repo methods so cubits load successfully
    when(() => mockSystemRepo.getSystemInfo()).thenAnswer(
      (_) async => (systemInfo: makeSystemInfo(), memory: makeMemoryUtilization()),
    );
    when(() => mockSystemRepo.getArrayData()).thenAnswer(
      (_) async => makeArrayData(),
    );
    when(() => mockDockerRepo.getContainers()).thenAnswer(
      (_) async => <DockerContainer>[],
    );
    when(() => mockVmRepo.getVms()).thenAnswer(
      (_) async => <VmDomain>[],
    );
    when(() => mockShareRepo.getShares()).thenAnswer(
      (_) async => <Share>[],
    );

    await resetGetIt();
    registerMockRepositories(
      systemRepo: mockSystemRepo,
      dockerRepo: mockDockerRepo,
      vmRepo: mockVmRepo,
      shareRepo: mockShareRepo,
    );
  });

  group('HomeScreen', () {
    testWidgets('displays app bar with title', (tester) async {
      await tester.pumpApp(const HomeScreen());
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      expect(find.text('Unraid Manager'), findsOneWidget);
    });

    testWidgets('displays refresh button in app bar', (tester) async {
      await tester.pumpApp(const HomeScreen());
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.byTooltip('Refresh'), findsOneWidget);
    });

    testWidgets('displays bottom navigation bar with 4 tabs', (tester) async {
      await tester.pumpApp(const HomeScreen());
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Main'), findsOneWidget);
      expect(find.text('Docker'), findsOneWidget);
      expect(find.text('VMs'), findsOneWidget);
      expect(find.text('Shares'), findsOneWidget);
    });

    testWidgets('displays navigation icons', (tester) async {
      await tester.pumpApp(const HomeScreen());
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // Selected tab shows filled icon; unselected tabs show outlined icons.
      // NavigationBar may render both in the tree, so use findsWidgets.
      expect(find.byIcon(Icons.dashboard), findsWidgets);
      expect(find.byIcon(Icons.inventory_2_outlined), findsWidgets);
      expect(find.byIcon(Icons.computer_outlined), findsWidgets);
      expect(find.byIcon(Icons.folder_shared_outlined), findsWidgets);
    });

    testWidgets('displays disconnect menu option', (tester) async {
      await tester.pumpApp(const HomeScreen());
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // Open popup menu
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('Disconnect'), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets('main tab is selected by default', (tester) async {
      await tester.pumpApp(const HomeScreen());
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      final navigationBar = tester.widget<NavigationBar>(
        find.byType(NavigationBar),
      );
      expect(navigationBar.selectedIndex, 0);
    });

    testWidgets('refresh button calls SystemCubit.refresh on main tab', (tester) async {
      await tester.pumpApp(const HomeScreen());
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // Tap refresh button
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      // Verify SystemCubit methods were called (initial load + refresh)
      verify(() => mockSystemRepo.getSystemInfo()).called(greaterThanOrEqualTo(2));
      verify(() => mockSystemRepo.getArrayData()).called(greaterThanOrEqualTo(2));
    });

    testWidgets('refresh button calls DockerCubit.refresh on docker tab', (tester) async {
      await tester.pumpApp(const HomeScreen());
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      // Switch to Docker tab
      await tester.tap(find.text('Docker'));
      await tester.pumpAndSettle();

      // Reset mock to count only refresh calls
      reset(mockDockerRepo);

      // Tap refresh button
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      // Verify DockerCubit.refresh was called
      verify(() => mockDockerRepo.getContainers()).called(1);
    });
  });
}
