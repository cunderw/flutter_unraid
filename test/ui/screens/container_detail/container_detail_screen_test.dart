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

  setUp(() {
    mockDockerCubit = MockDockerCubit();
    mockDockerRepo = MockDockerRepository();
    resetGetIt();
    registerMockRepositories(dockerRepo: mockDockerRepo);
  });

  group('ContainerDetailScreen', () {
    testWidgets('displays container not found when container is missing', (tester) async {
      await tester.pumpAppWithBlocs(
        const ContainerDetailScreen(containerId: 'missing-id'),
        dockerCubit: mockDockerCubit,
        dockerState: const DockerLoaded([]),
      );

      expect(find.text('Container not found.'), findsOneWidget);
    });

    testWidgets('displays container name in app bar when container exists', (tester) async {
      final container = makeRunningContainer(id: 'c1');
      await tester.pumpAppWithBlocs(
        const ContainerDetailScreen(containerId: 'c1'),
        dockerCubit: mockDockerCubit,
        dockerState: DockerLoaded([container]),
      );

      expect(find.text('test-container'), findsOneWidget);
    });

    testWidgets('displays all sections when container exists', (tester) async {
      final container = makeRunningContainer(id: 'c1');
      await tester.pumpAppWithBlocs(
        const ContainerDetailScreen(containerId: 'c1'),
        dockerCubit: mockDockerCubit,
        dockerState: DockerLoaded([container]),
      );

      expect(find.byType(ContainerStatusSection), findsOneWidget);
      expect(find.byType(ContainerActionsSection), findsOneWidget);
      expect(find.byType(ContainerConfigSection), findsOneWidget);
      expect(find.byType(ContainerLogsSection), findsOneWidget);
    });

    testWidgets('displays ports section only when container has ports', (tester) async {
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

      expect(find.text('Ports'), findsOneWidget);
    });

    testWidgets('hides ports section when container has no ports', (tester) async {
      final containerNoPorts = makeDockerContainer(id: 'c1', state: 'RUNNING', ports: []);
      await tester.pumpAppWithBlocs(
        const ContainerDetailScreen(containerId: 'c1'),
        dockerCubit: mockDockerCubit,
        dockerState: DockerLoaded([containerNoPorts]),
      );

      expect(find.text('Ports'), findsNothing);
    });

    testWidgets('displays Container as default title when container is null', (tester) async {
      await tester.pumpAppWithBlocs(
        const ContainerDetailScreen(containerId: 'missing'),
        dockerCubit: mockDockerCubit,
        dockerState: const DockerLoaded([]),
      );

      expect(find.text('Container'), findsOneWidget);
    });
  });
}
