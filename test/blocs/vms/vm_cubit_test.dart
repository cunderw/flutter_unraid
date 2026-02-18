import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_unraid/blocs/vms/vm_cubit.dart';
import 'package:flutter_unraid/blocs/vms/vm_state.dart';
import 'package:flutter_unraid/data/models/vm_domain.dart';
import 'package:flutter_unraid/data/repositories/vm_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockVmRepository extends Mock implements VmRepository {}

void main() {
  late MockVmRepository mockRepository;

  setUp(() {
    mockRepository = MockVmRepository();
  });

  group('VmCubit', () {
    test('initial state is VmInitial', () {
      final cubit = VmCubit(mockRepository);
      expect(cubit.state, const VmInitial());
      cubit.close();
    });

    group('load', () {
      final mockVms = [
        const VmDomain(id: 'vm1', name: 'Test VM 1', state: 'RUNNING'),
        const VmDomain(id: 'vm2', name: 'Test VM 2', state: 'SHUTOFF'),
      ];

      blocTest<VmCubit, VmState>(
        'emits [VmLoading, VmLoaded] when load succeeds',
        build: () {
          when(() => mockRepository.getVms()).thenAnswer((_) async => mockVms);
          return VmCubit(mockRepository);
        },
        act: (cubit) => cubit.load(),
        expect: () => [
          const VmLoading(),
          VmLoaded(mockVms),
        ],
        verify: (_) {
          verify(() => mockRepository.getVms()).called(1);
        },
      );

      blocTest<VmCubit, VmState>(
        'emits [VmLoading, VmError] when load fails',
        build: () {
          when(() => mockRepository.getVms())
              .thenThrow(Exception('Network error'));
          return VmCubit(mockRepository);
        },
        act: (cubit) => cubit.load(),
        expect: () => [
          const VmLoading(),
          const VmError('Unexpected error during loading VMs.'),
        ],
      );
    });

    group('refresh', () {
      blocTest<VmCubit, VmState>(
        'calls load',
        build: () {
          when(() => mockRepository.getVms()).thenAnswer((_) async => []);
          return VmCubit(mockRepository);
        },
        act: (cubit) => cubit.refresh(),
        expect: () => [
          const VmLoading(),
          const VmLoaded([]),
        ],
      );
    });

    group('startVm', () {
      final mockVms = [
        const VmDomain(id: 'vm1', name: 'Test VM', state: 'RUNNING'),
      ];

      blocTest<VmCubit, VmState>(
        'starts VM and reloads when successful',
        build: () {
          when(() => mockRepository.startVm(any()))
              .thenAnswer((_) async => {});
          when(() => mockRepository.getVms()).thenAnswer((_) async => mockVms);
          return VmCubit(mockRepository);
        },
        act: (cubit) => cubit.startVm('vm1'),
        expect: () => [
          const VmLoading(),
          VmLoaded(mockVms),
        ],
        verify: (_) {
          verify(() => mockRepository.startVm('vm1')).called(1);
          verify(() => mockRepository.getVms()).called(1);
        },
      );

      blocTest<VmCubit, VmState>(
        'emits VmActionError when startVm fails from loaded state',
        build: () {
          when(() => mockRepository.startVm(any()))
              .thenThrow(Exception('Failed to start'));
          return VmCubit(mockRepository);
        },
        seed: () => VmLoaded(mockVms),
        act: (cubit) => cubit.startVm('vm1'),
        expect: () => [
          VmActionError(
            vms: mockVms,
            message: 'Unexpected error during start VM.',
          ),
        ],
      );
    });

    group('stopVm', () {
      final mockVms = [
        const VmDomain(id: 'vm1', name: 'Test VM', state: 'SHUTOFF'),
      ];

      blocTest<VmCubit, VmState>(
        'stops VM and reloads when successful',
        build: () {
          when(() => mockRepository.stopVm(any())).thenAnswer((_) async => {});
          when(() => mockRepository.getVms()).thenAnswer((_) async => mockVms);
          return VmCubit(mockRepository);
        },
        act: (cubit) => cubit.stopVm('vm1'),
        expect: () => [
          const VmLoading(),
          VmLoaded(mockVms),
        ],
        verify: (_) {
          verify(() => mockRepository.stopVm('vm1')).called(1);
          verify(() => mockRepository.getVms()).called(1);
        },
      );

      blocTest<VmCubit, VmState>(
        'emits VmActionError when stopVm fails from loaded state',
        build: () {
          when(() => mockRepository.stopVm(any()))
              .thenThrow(Exception('Failed to stop'));
          return VmCubit(mockRepository);
        },
        seed: () => VmLoaded(mockVms),
        act: (cubit) => cubit.stopVm('vm1'),
        expect: () => [
          VmActionError(
            vms: mockVms,
            message: 'Unexpected error during stop VM.',
          ),
        ],
      );
    });

    group('forceStopVm', () {
      final mockVms = [
        const VmDomain(id: 'vm1', name: 'Test VM', state: 'SHUTOFF'),
      ];

      blocTest<VmCubit, VmState>(
        'force stops VM and reloads when successful',
        build: () {
          when(() => mockRepository.forceStopVm(any()))
              .thenAnswer((_) async => {});
          when(() => mockRepository.getVms()).thenAnswer((_) async => mockVms);
          return VmCubit(mockRepository);
        },
        act: (cubit) => cubit.forceStopVm('vm1'),
        expect: () => [
          const VmLoading(),
          VmLoaded(mockVms),
        ],
        verify: (_) {
          verify(() => mockRepository.forceStopVm('vm1')).called(1);
        },
      );
    });

    group('pauseVm', () {
      final mockVms = [
        const VmDomain(id: 'vm1', name: 'Test VM', state: 'PAUSED'),
      ];

      blocTest<VmCubit, VmState>(
        'pauses VM and reloads when successful',
        build: () {
          when(() => mockRepository.pauseVm(any()))
              .thenAnswer((_) async => {});
          when(() => mockRepository.getVms()).thenAnswer((_) async => mockVms);
          return VmCubit(mockRepository);
        },
        act: (cubit) => cubit.pauseVm('vm1'),
        expect: () => [
          const VmLoading(),
          VmLoaded(mockVms),
        ],
        verify: (_) {
          verify(() => mockRepository.pauseVm('vm1')).called(1);
        },
      );
    });

    group('resumeVm', () {
      final mockVms = [
        const VmDomain(id: 'vm1', name: 'Test VM', state: 'RUNNING'),
      ];

      blocTest<VmCubit, VmState>(
        'resumes VM and reloads when successful',
        build: () {
          when(() => mockRepository.resumeVm(any()))
              .thenAnswer((_) async => {});
          when(() => mockRepository.getVms()).thenAnswer((_) async => mockVms);
          return VmCubit(mockRepository);
        },
        act: (cubit) => cubit.resumeVm('vm1'),
        expect: () => [
          const VmLoading(),
          VmLoaded(mockVms),
        ],
        verify: (_) {
          verify(() => mockRepository.resumeVm('vm1')).called(1);
        },
      );
    });

    group('rebootVm', () {
      final mockVms = [
        const VmDomain(id: 'vm1', name: 'Test VM', state: 'RUNNING'),
      ];

      blocTest<VmCubit, VmState>(
        'reboots VM and reloads when successful',
        build: () {
          when(() => mockRepository.rebootVm(any()))
              .thenAnswer((_) async => {});
          when(() => mockRepository.getVms()).thenAnswer((_) async => mockVms);
          return VmCubit(mockRepository);
        },
        act: (cubit) => cubit.rebootVm('vm1'),
        expect: () => [
          const VmLoading(),
          VmLoaded(mockVms),
        ],
        verify: (_) {
          verify(() => mockRepository.rebootVm('vm1')).called(1);
        },
      );
    });
  });
}
