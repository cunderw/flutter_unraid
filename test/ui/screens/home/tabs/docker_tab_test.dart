import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_unraid/blocs/docker/docker_state.dart';
import 'package:flutter_unraid/ui/screens/home/tabs/docker_tab.dart';
import 'package:flutter_unraid/ui/widgets/feedback/empty_state.dart';
import 'package:flutter_unraid/ui/widgets/feedback/error_display.dart';
import 'package:flutter_unraid/ui/widgets/feedback/loading_indicator.dart';

import '../../../../helpers/factories.dart';
import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_helpers.dart';

void main() {
  late MockDockerCubit mockDockerCubit;

  setUp(() {
    mockDockerCubit = MockDockerCubit();
  });

  group('DockerTab', () {
    testWidgets('displays loading indicator when DockerInitial', (tester) async {
      await tester.pumpAppWithBlocs(
        const DockerTab(),
        dockerCubit: mockDockerCubit,
        dockerState: const DockerInitial(),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LoadingIndicator), findsOneWidget);
      expect(find.text('Loading containers...'), findsOneWidget);
    });

    testWidgets('displays loading indicator when DockerLoading', (tester) async {
      await tester.pumpAppWithBlocs(
        const DockerTab(),
        dockerCubit: mockDockerCubit,
        dockerState: const DockerLoading(),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LoadingIndicator), findsOneWidget);
    });

    testWidgets('displays error display when DockerError', (tester) async {
      await tester.pumpAppWithBlocs(
        const DockerTab(),
        dockerCubit: mockDockerCubit,
        dockerState: const DockerError('Failed to load containers'),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ErrorDisplay), findsOneWidget);
      expect(find.text('Failed to load containers'), findsOneWidget);
    });

    testWidgets('displays empty state when no containers', (tester) async {
      await tester.pumpAppWithBlocs(
        const DockerTab(),
        dockerCubit: mockDockerCubit,
        dockerState: const DockerLoaded([]),
      );
      await tester.pumpAndSettle();

      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('No Docker containers found.'), findsOneWidget);
      expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
    });

    testWidgets('displays containers when DockerLoaded with data', (tester) async {
      final containers = [
        makeRunningContainer(id: 'c1'),
        makeStoppedContainer(id: 'c2'),
      ];

      await tester.pumpAppWithBlocs(
        const DockerTab(),
        dockerCubit: mockDockerCubit,
        dockerState: DockerLoaded(containers),
      );
      await tester.pumpAndSettle();

      expect(find.text('Containers'), findsOneWidget);
      expect(find.text('1 running / 2 total'), findsOneWidget);
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('displays container tiles with status badges', (tester) async {
      final containers = [
        makeRunningContainer(id: 'c1'),
        makeStoppedContainer(id: 'c2'),
      ];

      await tester.pumpAppWithBlocs(
        const DockerTab(),
        dockerCubit: mockDockerCubit,
        dockerState: DockerLoaded(containers),
      );
      await tester.pumpAndSettle();

      // Should display container names
      expect(find.text('test-container'), findsNWidgets(2));
      
      // Should display container images
      expect(find.text('nginx:latest'), findsNWidgets(2));
    });

    testWidgets('displays action buttons for running containers', (tester) async {
      final containers = [makeRunningContainer()];

      await tester.pumpAppWithBlocs(
        const DockerTab(),
        dockerCubit: mockDockerCubit,
        dockerState: DockerLoaded(containers),
      );
      await tester.pumpAndSettle();

      expect(find.text('Stop'), findsOneWidget);
      expect(find.text('Restart'), findsOneWidget);
    });

    testWidgets('displays start button for stopped containers', (tester) async {
      final containers = [makeStoppedContainer()];

      await tester.pumpAppWithBlocs(
        const DockerTab(),
        dockerCubit: mockDockerCubit,
        dockerState: DockerLoaded(containers),
      );
      await tester.pumpAndSettle();

      expect(find.text('Start'), findsOneWidget);
    });

    testWidgets('displays container icons', (tester) async {
      final containers = [makeRunningContainer()];

      await tester.pumpAppWithBlocs(
        const DockerTab(),
        dockerCubit: mockDockerCubit,
        dockerState: DockerLoaded(containers),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.inventory_2), findsOneWidget);
    });
  });
}
