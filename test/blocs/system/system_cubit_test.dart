import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_unraid/blocs/system/system_cubit.dart';
import 'package:flutter_unraid/blocs/system/system_state.dart';

import '../../helpers/factories.dart';
import '../../helpers/mocks.dart';

void main() {
  late MockSystemRepository mockRepo;

  setUp(() {
    mockRepo = MockSystemRepository();
  });

  SystemCubit buildCubit() => SystemCubit(mockRepo);

  final systemInfo = makeSystemInfo();
  final memory = makeMemoryUtilization();
  final arrayData = makeArrayData();

  group('SystemCubit', () {
    test('initial state is SystemInitial', () {
      expect(buildCubit().state, const SystemInitial());
    });

    group('load', () {
      blocTest<SystemCubit, SystemState>(
        'emits [SystemLoading, SystemLoaded] on success',
        build: () {
          when(
            () => mockRepo.getSystemInfo(),
          ).thenAnswer((_) async => (systemInfo: systemInfo, memory: memory));
          when(
            () => mockRepo.getArrayData(),
          ).thenAnswer((_) async => arrayData);
          return buildCubit();
        },
        act: (cubit) => cubit.load(),
        expect: () => [
          const SystemLoading(),
          isA<SystemLoaded>()
              .having((s) => s.systemInfo, 'systemInfo', same(systemInfo))
              .having((s) => s.memory, 'memory', same(memory))
              .having((s) => s.arrayData, 'arrayData', same(arrayData)),
        ],
      );

      blocTest<SystemCubit, SystemState>(
        'emits [SystemLoading, SystemLoaded] with null memory',
        build: () {
          when(
            () => mockRepo.getSystemInfo(),
          ).thenAnswer((_) async => (systemInfo: systemInfo, memory: null));
          when(
            () => mockRepo.getArrayData(),
          ).thenAnswer((_) async => arrayData);
          return buildCubit();
        },
        act: (cubit) => cubit.load(),
        expect: () => [
          const SystemLoading(),
          isA<SystemLoaded>().having((s) => s.memory, 'memory', isNull),
        ],
      );

      blocTest<SystemCubit, SystemState>(
        'emits [SystemLoading, SystemError] on failure',
        build: () {
          when(() => mockRepo.getSystemInfo()).thenThrow(Exception('fail'));
          when(
            () => mockRepo.getArrayData(),
          ).thenAnswer((_) async => arrayData);
          return buildCubit();
        },
        act: (cubit) => cubit.load(),
        expect: () => [const SystemLoading(), isA<SystemError>()],
      );
    });

    group('setArrayState', () {
      blocTest<SystemCubit, SystemState>(
        'calls repository and reloads on success',
        seed: () => SystemLoaded(
          systemInfo: systemInfo,
          memory: memory,
          arrayData: arrayData,
        ),
        build: () {
          when(() => mockRepo.setArrayState(any())).thenAnswer((_) async {});
          when(
            () => mockRepo.getSystemInfo(),
          ).thenAnswer((_) async => (systemInfo: systemInfo, memory: memory));
          when(
            () => mockRepo.getArrayData(),
          ).thenAnswer((_) async => arrayData);
          return buildCubit();
        },
        act: (cubit) => cubit.setArrayState('STOP'),
        expect: () => [const SystemLoading(), isA<SystemLoaded>()],
        verify: (_) {
          verify(() => mockRepo.setArrayState('STOP')).called(1);
        },
      );

      blocTest<SystemCubit, SystemState>(
        'emits SystemActionError when action fails and state is SystemLoaded',
        seed: () => SystemLoaded(
          systemInfo: systemInfo,
          memory: memory,
          arrayData: arrayData,
        ),
        build: () {
          when(
            () => mockRepo.setArrayState(any()),
          ).thenThrow(Exception('fail'));
          return buildCubit();
        },
        act: (cubit) => cubit.setArrayState('STOP'),
        expect: () => [isA<SystemActionError>()],
      );

      blocTest<SystemCubit, SystemState>(
        'emits SystemError when action fails and state is not SystemLoaded',
        build: () {
          when(
            () => mockRepo.setArrayState(any()),
          ).thenThrow(Exception('fail'));
          return buildCubit();
        },
        act: (cubit) => cubit.setArrayState('STOP'),
        expect: () => [isA<SystemError>()],
      );
    });
  });
}
