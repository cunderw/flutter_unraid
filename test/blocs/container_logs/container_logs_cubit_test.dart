import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_unraid/ui/screens/container_detail/cubit/container_logs_cubit.dart';
import 'package:flutter_unraid/ui/screens/container_detail/cubit/container_logs_state.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockDockerRepository mockRepo;

  setUp(() {
    mockRepo = MockDockerRepository();
  });

  ContainerLogsCubit buildCubit({String containerId = 'test-container'}) =>
      ContainerLogsCubit(mockRepo, containerId: containerId);

  group('ContainerLogsCubit', () {
    test('initial state is ContainerLogsInitial', () {
      expect(buildCubit().state, const ContainerLogsInitial());
    });

    group('load', () {
      final logLines = [
        {
          'timestamp': '2025-01-01T00:00:00Z',
          'message': 'Line 1',
          'stream': 'stdout',
        },
        {
          'timestamp': '2025-01-01T00:00:01Z',
          'message': 'Line 2',
          'stream': 'stdout',
        },
      ];

      blocTest<ContainerLogsCubit, ContainerLogsState>(
        'emits [ContainerLogsLoading, ContainerLogsLoaded] on success',
        build: () {
          when(
            () => mockRepo.getContainerLogs(any(), tail: any(named: 'tail')),
          ).thenAnswer((_) async => logLines);
          return buildCubit(containerId: 'c1');
        },
        act: (cubit) => cubit.load(),
        expect: () => [
          const ContainerLogsLoading(),
          ContainerLogsLoaded(logLines),
        ],
        verify: (_) {
          verify(() => mockRepo.getContainerLogs('c1')).called(1);
        },
      );

      blocTest<ContainerLogsCubit, ContainerLogsState>(
        'emits [ContainerLogsLoading, ContainerLogsLoaded] with empty logs',
        build: () {
          when(
            () => mockRepo.getContainerLogs(any(), tail: any(named: 'tail')),
          ).thenAnswer((_) async => []);
          return buildCubit();
        },
        act: (cubit) => cubit.load(),
        expect: () => [
          const ContainerLogsLoading(),
          const ContainerLogsLoaded([]),
        ],
      );

      blocTest<ContainerLogsCubit, ContainerLogsState>(
        'emits [ContainerLogsLoading, ContainerLogsError] on failure',
        build: () {
          when(
            () => mockRepo.getContainerLogs(any(), tail: any(named: 'tail')),
          ).thenThrow(Exception('fail'));
          return buildCubit();
        },
        act: (cubit) => cubit.load(),
        expect: () => [const ContainerLogsLoading(), isA<ContainerLogsError>()],
      );
    });

    group('refresh', () {
      blocTest<ContainerLogsCubit, ContainerLogsState>(
        'delegates to load',
        build: () {
          when(
            () => mockRepo.getContainerLogs(any(), tail: any(named: 'tail')),
          ).thenAnswer((_) async => []);
          return buildCubit();
        },
        act: (cubit) => cubit.refresh(),
        expect: () => [
          const ContainerLogsLoading(),
          const ContainerLogsLoaded([]),
        ],
      );
    });
  });
}
