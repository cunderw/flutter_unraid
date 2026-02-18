import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_unraid/blocs/docker/docker_cubit.dart';
import 'package:flutter_unraid/blocs/docker/docker_state.dart';

import '../../helpers/factories.dart';
import '../../helpers/mocks.dart';

void main() {
  late MockDockerRepository mockRepo;

  setUp(() {
    mockRepo = MockDockerRepository();
  });

  DockerCubit buildCubit() => DockerCubit(mockRepo);

  group('DockerCubit', () {
    test('initial state is DockerInitial', () {
      expect(buildCubit().state, const DockerInitial());
    });

    group('load', () {
      blocTest<DockerCubit, DockerState>(
        'emits [DockerLoading, DockerLoaded] on success',
        build: () {
          when(() => mockRepo.getContainers()).thenAnswer(
            (_) async => [makeRunningContainer(), makeStoppedContainer()],
          );
          return buildCubit();
        },
        act: (cubit) => cubit.load(),
        expect: () => [
          const DockerLoading(),
          isA<DockerLoaded>().having(
            (s) => s.containers.length,
            'container count',
            2,
          ),
        ],
      );

      blocTest<DockerCubit, DockerState>(
        'emits [DockerLoading, DockerError] on failure',
        build: () {
          when(() => mockRepo.getContainers()).thenThrow(Exception('fail'));
          return buildCubit();
        },
        act: (cubit) => cubit.load(),
        expect: () => [const DockerLoading(), isA<DockerError>()],
      );
    });

    group('startContainer', () {
      blocTest<DockerCubit, DockerState>(
        'calls repository and reloads on success',
        build: () {
          when(() => mockRepo.startContainer(any())).thenAnswer((_) async {});
          when(
            () => mockRepo.getContainers(),
          ).thenAnswer((_) async => [makeRunningContainer()]);
          return buildCubit();
        },
        act: (cubit) => cubit.startContainer('container-1'),
        expect: () => [const DockerLoading(), isA<DockerLoaded>()],
        verify: (_) {
          verify(() => mockRepo.startContainer('container-1')).called(1);
        },
      );

      blocTest<DockerCubit, DockerState>(
        'emits DockerActionError when action fails and state is DockerLoaded',
        seed: () => DockerLoaded([makeRunningContainer()]),
        build: () {
          when(
            () => mockRepo.startContainer(any()),
          ).thenThrow(Exception('fail'));
          return buildCubit();
        },
        act: (cubit) => cubit.startContainer('container-1'),
        expect: () => [isA<DockerActionError>()],
      );
    });

    group('stopContainer', () {
      blocTest<DockerCubit, DockerState>(
        'calls repository and reloads on success',
        build: () {
          when(() => mockRepo.stopContainer(any())).thenAnswer((_) async {});
          when(
            () => mockRepo.getContainers(),
          ).thenAnswer((_) async => [makeStoppedContainer()]);
          return buildCubit();
        },
        act: (cubit) => cubit.stopContainer('container-2'),
        expect: () => [const DockerLoading(), isA<DockerLoaded>()],
        verify: (_) {
          verify(() => mockRepo.stopContainer('container-2')).called(1);
        },
      );
    });

    group('restartContainer', () {
      blocTest<DockerCubit, DockerState>(
        'calls repository and reloads on success',
        build: () {
          when(() => mockRepo.restartContainer(any())).thenAnswer((_) async {});
          when(
            () => mockRepo.getContainers(),
          ).thenAnswer((_) async => [makeRunningContainer()]);
          return buildCubit();
        },
        act: (cubit) => cubit.restartContainer('container-1'),
        expect: () => [const DockerLoading(), isA<DockerLoaded>()],
        verify: (_) {
          verify(() => mockRepo.restartContainer('container-1')).called(1);
        },
      );
    });

    group('removeContainer', () {
      blocTest<DockerCubit, DockerState>(
        'calls repository with withImage flag and reloads',
        build: () {
          when(
            () => mockRepo.removeContainer(
              any(),
              withImage: any(named: 'withImage'),
            ),
          ).thenAnswer((_) async {});
          when(() => mockRepo.getContainers()).thenAnswer((_) async => []);
          return buildCubit();
        },
        act: (cubit) => cubit.removeContainer('container-1', withImage: true),
        expect: () => [
          const DockerLoading(),
          isA<DockerLoaded>().having(
            (s) => s.containers.length,
            'container count',
            0,
          ),
        ],
        verify: (_) {
          verify(
            () => mockRepo.removeContainer('container-1', withImage: true),
          ).called(1);
        },
      );

      blocTest<DockerCubit, DockerState>(
        'emits DockerError when action fails and state is not DockerLoaded',
        build: () {
          when(
            () => mockRepo.removeContainer(
              any(),
              withImage: any(named: 'withImage'),
            ),
          ).thenThrow(Exception('fail'));
          return buildCubit();
        },
        act: (cubit) => cubit.removeContainer('container-1'),
        expect: () => [isA<DockerError>()],
      );
    });

    group('DockerLoaded helpers', () {
      test('running and stopped counts are correct', () {
        final state = DockerLoaded([
          makeRunningContainer(id: 'c1'),
          makeStoppedContainer(id: 'c2'),
          makeRunningContainer(id: 'c3'),
        ]);
        expect(state.running, 2);
        expect(state.stopped, 1);
      });
    });
  });
}
