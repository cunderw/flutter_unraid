import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_unraid/ui/screens/home/home_screen.dart';

import '../../helpers/get_it_helpers.dart';
import '../../helpers/mocks.dart';
import '../../helpers/pump_helpers.dart';

void main() {
  late MockSystemRepository mockSystemRepo;
  late MockDockerRepository mockDockerRepo;
  late MockVmRepository mockVmRepo;
  late MockShareRepository mockShareRepo;

  setUp(() {
    mockSystemRepo = MockSystemRepository();
    mockDockerRepo = MockDockerRepository();
    mockVmRepo = MockVmRepository();
    mockShareRepo = MockShareRepository();
    
    resetGetIt();
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

      expect(find.text('Unraid Manager'), findsOneWidget);
    });

    testWidgets('displays refresh button in app bar', (tester) async {
      await tester.pumpApp(const HomeScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.byTooltip('Refresh'), findsOneWidget);
    });

    testWidgets('displays bottom navigation bar with 4 tabs', (tester) async {
      await tester.pumpApp(const HomeScreen());
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

      expect(find.byIcon(Icons.dashboard_outlined), findsOneWidget);
      expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
      expect(find.byIcon(Icons.computer_outlined), findsOneWidget);
      expect(find.byIcon(Icons.folder_shared_outlined), findsOneWidget);
    });

    testWidgets('displays disconnect menu option', (tester) async {
      await tester.pumpApp(const HomeScreen());
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

      final navigationBar = tester.widget<NavigationBar>(
        find.byType(NavigationBar),
      );
      expect(navigationBar.selectedIndex, 0);
    });
  });
}
