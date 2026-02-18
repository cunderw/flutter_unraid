import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_unraid/blocs/docker/docker_cubit.dart';
import 'package:flutter_unraid/blocs/docker/docker_state.dart';
import 'package:flutter_unraid/data/models/docker_container.dart';
import 'package:flutter_unraid/data/repositories/docker_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockDockerRepository extends Mock implements DockerRepository {}

void main() {
  late MockDockerRepository mockRepository;

  setUp(() {
    mockRepository = MockDockerRepository();
  });

  group('DockerCubit', () {
    test('initial state is DockerInitial', () {
      final cubit = DockerCubit(mockRepository);
      expect(cubit.state, const DockerInitial());
      cubit.close();
    });

    group('load', () {
      final mockContainers = [
        const DockerContainer(
          id: '1',
          names: ['/container1'],
          image: 'nginx',
          state: 'RUNNING',
          status: 'Up 2 hours',
          autoStart: true,
        ),
        const DockerContainer(
          id: '2',
          names: ['/container2'],
          image: 'redis',
          state: 'EXITED',
          status: 'Exited (0) 1 hour ago',
          autoStart: false,
        ),
      ];

      blocTest<DockerCubit, DockerState>(
        'emits [DockerLoading, DockerLoaded] when load succeeds',
        build: () {
          when(() => mockRepository.getContainers())
              .thenAnswer((_) async => mockContainers);
          return DockerCubit(mockRepository);
        },
        act: (cubit) => cubit.load(),
        expect: () => [
          const DockerLoading(),
          DockerLoaded(mockContainers),
        ],
        verify: (_) {
          verify(() => mockRepository.getContainers()).called(1);
        },
      );

      blocTest<DockerCubit, DockerState>(
        'emits [DockerLoading, DockerError] when load fails',
        build: () {
          when(() => mockRepository.getContainers())
              .thenThrow(Exception('Network error'));
          return DockerCubit(mockRepository);
        },
        act: (cubit) => cubit.load(),
        expect: () => [
          const DockerLoading(),
          const DockerError('Unexpected error during loading containers.'),
        ],
      );
    });

    group('refresh', () {
      blocTest<DockerCubit, DockerState>(
        'calls load',
        build: () {
          when(() => mockRepository.getContainers())
              .thenAnswer((_) async => []);
          return DockerCubit(mockRepository);
        },
        act: (cubit) => cubit.refresh(),
        expect: () => [
          const DockerLoading(),
          const DockerLoaded([]),
        ],
        verify: (_) {
          verify(() => mockRepository.getContainers()).called(1);
        },
      );
    });

    group('startContainer', () {
      final mockContainers = [
        const DockerContainer(
          id: '1',
          names: ['/container1'],
          image: 'nginx',
          state: 'RUNNING',
          status: 'Up 2 hours',
          autoStart: true,
        ),
      ];

      blocTest<DockerCubit, DockerState>(
        'starts container and reloads when successful',
        build: () {
          when(() => mockRepository.startContainer(any()))
              .thenAnswer((_) async => {});
          when(() => mockRepository.getContainers())
              .thenAnswer((_) async => mockContainers);
          return DockerCubit(mockRepository);
        },
        act: (cubit) => cubit.startContainer('1'),
        expect: () => [
          const DockerLoading(),
          DockerLoaded(mockContainers),
        ],
        verify: (_) {
          verify(() => mockRepository.startContainer('1')).called(1);
          verify(() => mockRepository.getContainers()).called(1);
        },
      );

      blocTest<DockerCubit, DockerState>(
        'emits DockerError when startContainer fails from initial state',
        build: () {
          when(() => mockRepository.startContainer(any()))
              .thenThrow(Exception('Failed to start'));
          return DockerCubit(mockRepository);
        },
        act: (cubit) => cubit.startContainer('1'),
        expect: () => [
          const DockerError('Unexpected error during starting container.'),
        ],
      );

      blocTest<DockerCubit, DockerState>(
        'emits DockerActionError when startContainer fails from loaded state',
        build: () {
          when(() => mockRepository.startContainer(any()))
              .thenThrow(Exception('Failed to start'));
          return DockerCubit(mockRepository);
        },
        seed: () => DockerLoaded(mockContainers),
        act: (cubit) => cubit.startContainer('1'),
        expect: () => [
          DockerActionError(
            containers: mockContainers,
            message: 'Unexpected error during starting container.',
          ),
        ],
      );
    });

    group('stopContainer', () {
      final mockContainers = [
        const DockerContainer(
          id: '1',
          names: ['/container1'],
          image: 'nginx',
          state: 'EXITED',
          status: 'Exited',
          autoStart: true,
        ),
      ];

      blocTest<DockerCubit, DockerState>(
        'stops container and reloads when successful',
        build: () {
          when(() => mockRepository.stopContainer(any()))
              .thenAnswer((_) async => {});
          when(() => mockRepository.getContainers())
              .thenAnswer((_) async => mockContainers);
          return DockerCubit(mockRepository);
        },
        act: (cubit) => cubit.stopContainer('1'),
        expect: () => [
          const DockerLoading(),
          DockerLoaded(mockContainers),
        ],
        verify: (_) {
          verify(() => mockRepository.stopContainer('1')).called(1);
          verify(() => mockRepository.getContainers()).called(1);
        },
      );

      blocTest<DockerCubit, DockerState>(
        'emits DockerActionError when stopContainer fails from loaded state',
        build: () {
          when(() => mockRepository.stopContainer(any()))
              .thenThrow(Exception('Failed to stop'));
          return DockerCubit(mockRepository);
        },
        seed: () => DockerLoaded(mockContainers),
        act: (cubit) => cubit.stopContainer('1'),
        expect: () => [
          DockerActionError(
            containers: mockContainers,
            message: 'Unexpected error during stopping container.',
          ),
        ],
      );
    });

    group('restartContainer', () {
      final mockContainers = [
        const DockerContainer(
          id: '1',
          names: ['/container1'],
          image: 'nginx',
          state: 'RUNNING',
          status: 'Up 1 second',
          autoStart: true,
        ),
      ];

      blocTest<DockerCubit, DockerState>(
        'restarts container and reloads when successful',
        build: () {
          when(() => mockRepository.restartContainer(any()))
              .thenAnswer((_) async => {});
          when(() => mockRepository.getContainers())
              .thenAnswer((_) async => mockContainers);
          return DockerCubit(mockRepository);
        },
        act: (cubit) => cubit.restartContainer('1'),
        expect: () => [
          const DockerLoading(),
          DockerLoaded(mockContainers),
        ],
        verify: (_) {
          verify(() => mockRepository.restartContainer('1')).called(1);
          verify(() => mockRepository.getContainers()).called(1);
        },
      );

      blocTest<DockerCubit, DockerState>(
        'emits DockerActionError when restartContainer fails from loaded state',
        build: () {
          when(() => mockRepository.restartContainer(any()))
              .thenThrow(Exception('Failed to restart'));
          return DockerCubit(mockRepository);
        },
        seed: () => DockerLoaded(mockContainers),
        act: (cubit) => cubit.restartContainer('1'),
        expect: () => [
          DockerActionError(
            containers: mockContainers,
            message: 'Unexpected error during restarting container.',
          ),
        ],
      );
    });

    group('removeContainer', () {
      final mockContainers = [
        const DockerContainer(
          id: '2',
          names: ['/container2'],
          image: 'redis',
          state: 'EXITED',
          status: 'Exited',
          autoStart: false,
        ),
      ];

      blocTest<DockerCubit, DockerState>(
        'removes container and reloads when successful',
        build: () {
          when(() => mockRepository.removeContainer(
                any(),
                withImage: any(named: 'withImage'),
              )).thenAnswer((_) async => {});
          when(() => mockRepository.getContainers())
              .thenAnswer((_) async => mockContainers);
          return DockerCubit(mockRepository);
        },
        act: (cubit) => cubit.removeContainer('1', withImage: false),
        expect: () => [
          const DockerLoading(),
          DockerLoaded(mockContainers),
        ],
        verify: (_) {
          verify(() => mockRepository.removeContainer('1', withImage: false))
              .called(1);
          verify(() => mockRepository.getContainers()).called(1);
        },
      );

      blocTest<DockerCubit, DockerState>(
        'removes container with image when withImage is true',
        build: () {
          when(() => mockRepository.removeContainer(
                any(),
                withImage: any(named: 'withImage'),
              )).thenAnswer((_) async => {});
          when(() => mockRepository.getContainers())
              .thenAnswer((_) async => mockContainers);
          return DockerCubit(mockRepository);
        },
        act: (cubit) => cubit.removeContainer('1', withImage: true),
        expect: () => [
          const DockerLoading(),
          DockerLoaded(mockContainers),
        ],
        verify: (_) {
          verify(() => mockRepository.removeContainer('1', withImage: true))
              .called(1);
        },
      );

      blocTest<DockerCubit, DockerState>(
        'emits DockerActionError when removeContainer fails from loaded state',
        build: () {
          when(() => mockRepository.removeContainer(
                any(),
                withImage: any(named: 'withImage'),
              )).thenThrow(Exception('Failed to remove'));
          return DockerCubit(mockRepository);
        },
        seed: () => DockerLoaded(mockContainers),
        act: (cubit) => cubit.removeContainer('1'),
        expect: () => [
          DockerActionError(
            containers: mockContainers,
            message: 'Unexpected error during removing container.',
          ),
        ],
      );
    });
  });
}
