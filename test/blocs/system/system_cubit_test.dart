import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_unraid/blocs/system/system_cubit.dart';
import 'package:flutter_unraid/blocs/system/system_state.dart';
import 'package:flutter_unraid/data/models/array_data.dart';
import 'package:flutter_unraid/data/models/system_info.dart';
import 'package:flutter_unraid/data/repositories/system_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockSystemRepository extends Mock implements SystemRepository {}

void main() {
  late MockSystemRepository mockRepository;

  setUp(() {
    mockRepository = MockSystemRepository();
  });

  const mockSystemInfo = SystemInfo(
    hostname: 'test-server',
    osInfo: OsInfo(
      platform: 'linux',
      distro: 'Unraid',
      release: '6.12.0',
      uptime: '5 days',
    ),
    cpuInfo: CpuInfo(
      manufacturer: 'Intel',
      brand: 'Core i7',
      cores: 4,
      threads: 8,
    ),
  );

  const mockMemory = MemoryUtilization(
    total: 16000000000,
    free: 8000000000,
    used: 8000000000,
    active: 7000000000,
    available: 9000000000,
    percentTotal: 50.0,
  );

  const mockArrayData = ArrayData(
    state: 'started',
    numDisks: 4,
    numDisabled: 0,
    numMissing: 0,
    numErrors: 0,
    capacity: ArrayCapacity(
      kilobytes: Capacity(free: '1000000', used: '500000', total: '1500000'),
      disks: Capacity(free: '2', used: '2', total: '4'),
    ),
    disks: [],
  );

  group('SystemCubit', () {
    test('initial state is SystemInitial', () {
      final cubit = SystemCubit(mockRepository);
      expect(cubit.state, const SystemInitial());
      cubit.close();
    });

    group('load', () {
      blocTest<SystemCubit, SystemState>(
        'emits [SystemLoading, SystemLoaded] when load succeeds',
        build: () {
          when(() => mockRepository.getSystemInfo()).thenAnswer(
            (_) async => (systemInfo: mockSystemInfo, memory: mockMemory),
          );
          when(() => mockRepository.getArrayData())
              .thenAnswer((_) async => mockArrayData);
          return SystemCubit(mockRepository);
        },
        act: (cubit) => cubit.load(),
        expect: () => [
          const SystemLoading(),
          const SystemLoaded(
            systemInfo: mockSystemInfo,
            memory: mockMemory,
            arrayData: mockArrayData,
          ),
        ],
        verify: (_) {
          verify(() => mockRepository.getSystemInfo()).called(1);
          verify(() => mockRepository.getArrayData()).called(1);
        },
      );

      blocTest<SystemCubit, SystemState>(
        'emits [SystemLoading, SystemLoaded] with null memory when memory is null',
        build: () {
          when(() => mockRepository.getSystemInfo()).thenAnswer(
            (_) async => (systemInfo: mockSystemInfo, memory: null),
          );
          when(() => mockRepository.getArrayData())
              .thenAnswer((_) async => mockArrayData);
          return SystemCubit(mockRepository);
        },
        act: (cubit) => cubit.load(),
        expect: () => [
          const SystemLoading(),
          const SystemLoaded(
            systemInfo: mockSystemInfo,
            memory: null,
            arrayData: mockArrayData,
          ),
        ],
      );

      blocTest<SystemCubit, SystemState>(
        'emits [SystemLoading, SystemError] when getSystemInfo fails',
        build: () {
          when(() => mockRepository.getSystemInfo())
              .thenThrow(Exception('Failed to get system info'));
          when(() => mockRepository.getArrayData())
              .thenAnswer((_) async => mockArrayData);
          return SystemCubit(mockRepository);
        },
        act: (cubit) => cubit.load(),
        expect: () => [
          const SystemLoading(),
          const SystemError('Unexpected error during loading system data.'),
        ],
      );

      blocTest<SystemCubit, SystemState>(
        'emits [SystemLoading, SystemError] when getArrayData fails',
        build: () {
          when(() => mockRepository.getSystemInfo()).thenAnswer(
            (_) async => (systemInfo: mockSystemInfo, memory: mockMemory),
          );
          when(() => mockRepository.getArrayData())
              .thenThrow(Exception('Failed to get array data'));
          return SystemCubit(mockRepository);
        },
        act: (cubit) => cubit.load(),
        expect: () => [
          const SystemLoading(),
          const SystemError('Unexpected error during loading system data.'),
        ],
      );
    });

    group('refresh', () {
      blocTest<SystemCubit, SystemState>(
        'calls load',
        build: () {
          when(() => mockRepository.getSystemInfo()).thenAnswer(
            (_) async => (systemInfo: mockSystemInfo, memory: mockMemory),
          );
          when(() => mockRepository.getArrayData())
              .thenAnswer((_) async => mockArrayData);
          return SystemCubit(mockRepository);
        },
        act: (cubit) => cubit.refresh(),
        expect: () => [
          const SystemLoading(),
          const SystemLoaded(
            systemInfo: mockSystemInfo,
            memory: mockMemory,
            arrayData: mockArrayData,
          ),
        ],
      );
    });

    group('setArrayState', () {
      blocTest<SystemCubit, SystemState>(
        'sets array state and reloads when successful',
        build: () {
          when(() => mockRepository.setArrayState(any()))
              .thenAnswer((_) async => {});
          when(() => mockRepository.getSystemInfo()).thenAnswer(
            (_) async => (systemInfo: mockSystemInfo, memory: mockMemory),
          );
          when(() => mockRepository.getArrayData())
              .thenAnswer((_) async => mockArrayData);
          return SystemCubit(mockRepository);
        },
        act: (cubit) => cubit.setArrayState('started'),
        expect: () => [
          const SystemLoading(),
          const SystemLoaded(
            systemInfo: mockSystemInfo,
            memory: mockMemory,
            arrayData: mockArrayData,
          ),
        ],
        verify: (_) {
          verify(() => mockRepository.setArrayState('started')).called(1);
          verify(() => mockRepository.getSystemInfo()).called(1);
          verify(() => mockRepository.getArrayData()).called(1);
        },
      );

      blocTest<SystemCubit, SystemState>(
        'emits SystemError when setArrayState fails from initial state',
        build: () {
          when(() => mockRepository.setArrayState(any()))
              .thenThrow(Exception('Failed to set array state'));
          return SystemCubit(mockRepository);
        },
        act: (cubit) => cubit.setArrayState('stopped'),
        expect: () => [
          const SystemError('Unexpected error during setting array state.'),
        ],
      );

      blocTest<SystemCubit, SystemState>(
        'emits SystemActionError when setArrayState fails from loaded state',
        build: () {
          when(() => mockRepository.setArrayState(any()))
              .thenThrow(Exception('Failed to set array state'));
          return SystemCubit(mockRepository);
        },
        seed: () => const SystemLoaded(
          systemInfo: mockSystemInfo,
          memory: mockMemory,
          arrayData: mockArrayData,
        ),
        act: (cubit) => cubit.setArrayState('stopped'),
        expect: () => [
          const SystemActionError(
            systemInfo: mockSystemInfo,
            memory: mockMemory,
            arrayData: mockArrayData,
            message: 'Unexpected error during setting array state.',
          ),
        ],
      );

      blocTest<SystemCubit, SystemState>(
        'emits SystemActionError when setArrayState fails from action error state',
        build: () {
          when(() => mockRepository.setArrayState(any()))
              .thenThrow(Exception('Failed to set array state'));
          return SystemCubit(mockRepository);
        },
        seed: () => const SystemActionError(
          systemInfo: mockSystemInfo,
          memory: mockMemory,
          arrayData: mockArrayData,
          message: 'Previous error',
        ),
        act: (cubit) => cubit.setArrayState('stopped'),
        expect: () => [
          const SystemActionError(
            systemInfo: mockSystemInfo,
            memory: mockMemory,
            arrayData: mockArrayData,
            message: 'Unexpected error during setting array state.',
          ),
        ],
      );
    });
  });
}
