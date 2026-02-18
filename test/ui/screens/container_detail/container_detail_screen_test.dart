import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_unraid/blocs/docker/docker_state.dart';
import 'package:flutter_unraid/ui/screens/container_detail/container_detail_screen.dart';
import 'package:flutter_unraid/ui/screens/container_detail/container_status_section.dart';
import 'package:flutter_unraid/ui/screens/container_detail/container_actions_section.dart';
import 'package:flutter_unraid/ui/screens/container_detail/container_config_section.dart';
import 'package:flutter_unraid/ui/screens/container_detail/container_logs_section.dart';

import '../../../helpers/factories.dart';
import '../../../helpers/mocks.dart';
import '../../../helpers/pump_helpers.dart';
import '../../../helpers/get_it_helpers.dart';

void main() {
  late MockDockerCubit mockDockerCubit;
  late MockDockerRepository mockDockerRepo;

  setUp(() async {
    mockDockerCubit = MockDockerCubit();
    mockDockerRepo = MockDockerRepository();
    await resetGetIt();
    registerMockRepositories(dockerRepo: mockDockerRepo);
  });

  group('ContainerDetailScreen', () {
    testWidgets('displays container not found when container is missing', (
      tester,
    ) async {
      await tester.pumpAppWithBlocs(
        const ContainerDetailScreen(containerId: 'missing-id'),
        dockerCubit: mockDockerCubit,
        dockerState: const DockerLoaded([]),
      );
      await tester.pumpAndSettle();

      expect(find.text('Container not found.'), findsOneWidget);
    });

    testWidgets('displays container name in app bar when container exists', (
      tester,
    ) async {
      final container = makeRunningContainer(id: 'c1');
      await tester.pumpAppWithBlocs(
        const ContainerDetailScreen(containerId: 'c1'),
        dockerCubit: mockDockerCubit,
        dockerState: DockerLoaded([container]),
      );
      await tester.pumpAndSettle();

      // Name appears in both AppBar and status section
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('test-container'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('displays all sections when container exists', (tester) async {
      final container = makeRunningContainer(id: 'c1');
      await tester.pumpAppWithBlocs(
        const ContainerDetailScreen(containerId: 'c1'),
        dockerCubit: mockDockerCubit,
        dockerState: DockerLoaded([container]),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ContainerStatusSection), findsOneWidget);
      expect(find.byType(ContainerActionsSection), findsOneWidget);
      expect(find.byType(ContainerConfigSection), findsOneWidget);

      // ContainerLogsSection is at the bottom of the ListView;
      // scroll down so the lazy list builds it.
      await tester.scrollUntilVisible(find.byType(ContainerLogsSection), 200);
      expect(find.byType(ContainerLogsSection), findsOneWidget);
    });

    testWidgets('displays ports section only when container has ports', (
      tester,
    ) async {
      final containerWithPorts = makeDockerContainer(
        id: 'c1',
        state: 'RUNNING',
        ports: [makeContainerPort()],
      );
      await tester.pumpAppWithBlocs(
        const ContainerDetailScreen(containerId: 'c1'),
        dockerCubit: mockDockerCubit,
        dockerState: DockerLoaded([containerWithPorts]),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ports'), findsOneWidget);
    });

    testWidgets('hides ports section when container has no ports', (
      tester,
    ) async {
      final containerNoPorts = makeDockerContainer(
        id: 'c1',
        state: 'RUNNING',
        ports: [],
      );
      await tester.pumpAppWithBlocs(
        const ContainerDetailScreen(containerId: 'c1'),
        dockerCubit: mockDockerCubit,
        dockerState: DockerLoaded([containerNoPorts]),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ports'), findsNothing);
    });

    testWidgets('displays Container as default title when container is null', (
      tester,
    ) async {
      await tester.pumpAppWithBlocs(
        const ContainerDetailScreen(containerId: 'missing'),
        dockerCubit: mockDockerCubit,
        dockerState: const DockerLoaded([]),
      );
      await tester.pumpAndSettle();

      expect(find.text('Container'), findsOneWidget);
    });
  });
}
