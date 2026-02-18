import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_unraid/blocs/vms/vm_cubit.dart';
import 'package:flutter_unraid/blocs/vms/vm_state.dart';

import '../../helpers/factories.dart';
import '../../helpers/mocks.dart';

void main() {
  late MockVmRepository mockRepo;

  setUp(() {
    mockRepo = MockVmRepository();
  });

  VmCubit buildCubit() => VmCubit(mockRepo);

  group('VmCubit', () {
    test('initial state is VmInitial', () {
      expect(buildCubit().state, const VmInitial());
    });

    group('load', () {
      blocTest<VmCubit, VmState>(
        'emits [VmLoading, VmLoaded] on success',
        build: () {
          when(
            () => mockRepo.getVms(),
          ).thenAnswer((_) async => [makeRunningVm(), makeStoppedVm()]);
          return buildCubit();
        },
        act: (cubit) => cubit.load(),
        expect: () => [
          const VmLoading(),
          isA<VmLoaded>().having((s) => s.vms.length, 'vm count', 2),
        ],
      );

      blocTest<VmCubit, VmState>(
        'emits [VmLoading, VmError] on failure',
        build: () {
          when(() => mockRepo.getVms()).thenThrow(Exception('fail'));
          return buildCubit();
        },
        act: (cubit) => cubit.load(),
        expect: () => [const VmLoading(), isA<VmError>()],
      );
    });

    group('startVm', () {
      blocTest<VmCubit, VmState>(
        'calls repository and reloads on success',
        build: () {
          when(() => mockRepo.startVm(any())).thenAnswer((_) async {});
          when(
            () => mockRepo.getVms(),
          ).thenAnswer((_) async => [makeRunningVm()]);
          return buildCubit();
        },
        act: (cubit) => cubit.startVm('vm-1'),
        expect: () => [const VmLoading(), isA<VmLoaded>()],
        verify: (_) {
          verify(() => mockRepo.startVm('vm-1')).called(1);
        },
      );

      blocTest<VmCubit, VmState>(
        'emits VmActionError when action fails and state is VmLoaded',
        seed: () => VmLoaded([makeRunningVm()]),
        build: () {
          when(() => mockRepo.startVm(any())).thenThrow(Exception('fail'));
          return buildCubit();
        },
        act: (cubit) => cubit.startVm('vm-1'),
        expect: () => [isA<VmActionError>()],
      );
    });

    group('stopVm', () {
      blocTest<VmCubit, VmState>(
        'calls repository and reloads on success',
        build: () {
          when(() => mockRepo.stopVm(any())).thenAnswer((_) async {});
          when(
            () => mockRepo.getVms(),
          ).thenAnswer((_) async => [makeStoppedVm()]);
          return buildCubit();
        },
        act: (cubit) => cubit.stopVm('vm-2'),
        expect: () => [const VmLoading(), isA<VmLoaded>()],
        verify: (_) {
          verify(() => mockRepo.stopVm('vm-2')).called(1);
        },
      );
    });

    group('forceStopVm', () {
      blocTest<VmCubit, VmState>(
        'calls repository and reloads on success',
        build: () {
          when(() => mockRepo.forceStopVm(any())).thenAnswer((_) async {});
          when(() => mockRepo.getVms()).thenAnswer((_) async => []);
          return buildCubit();
        },
        act: (cubit) => cubit.forceStopVm('vm-1'),
        expect: () => [
          const VmLoading(),
          isA<VmLoaded>().having((s) => s.vms.length, 'vm count', 0),
        ],
        verify: (_) {
          verify(() => mockRepo.forceStopVm('vm-1')).called(1);
        },
      );
    });

    group('pauseVm', () {
      blocTest<VmCubit, VmState>(
        'calls repository and reloads on success',
        build: () {
          when(() => mockRepo.pauseVm(any())).thenAnswer((_) async {});
          when(
            () => mockRepo.getVms(),
          ).thenAnswer((_) async => [makePausedVm()]);
          return buildCubit();
        },
        act: (cubit) => cubit.pauseVm('vm-3'),
        expect: () => [const VmLoading(), isA<VmLoaded>()],
        verify: (_) {
          verify(() => mockRepo.pauseVm('vm-3')).called(1);
        },
      );
    });

    group('resumeVm', () {
      blocTest<VmCubit, VmState>(
        'calls repository and reloads on success',
        build: () {
          when(() => mockRepo.resumeVm(any())).thenAnswer((_) async {});
          when(
            () => mockRepo.getVms(),
          ).thenAnswer((_) async => [makeRunningVm()]);
          return buildCubit();
        },
        act: (cubit) => cubit.resumeVm('vm-1'),
        expect: () => [const VmLoading(), isA<VmLoaded>()],
        verify: (_) {
          verify(() => mockRepo.resumeVm('vm-1')).called(1);
        },
      );
    });

    group('rebootVm', () {
      blocTest<VmCubit, VmState>(
        'calls repository and reloads on success',
        build: () {
          when(() => mockRepo.rebootVm(any())).thenAnswer((_) async {});
          when(
            () => mockRepo.getVms(),
          ).thenAnswer((_) async => [makeRunningVm()]);
          return buildCubit();
        },
        act: (cubit) => cubit.rebootVm('vm-1'),
        expect: () => [const VmLoading(), isA<VmLoaded>()],
        verify: (_) {
          verify(() => mockRepo.rebootVm('vm-1')).called(1);
        },
      );
    });

    group('VmLoaded helpers', () {
      test('running and stopped counts are correct', () {
        final state = VmLoaded([
          makeRunningVm(id: 'v1'),
          makeStoppedVm(id: 'v2'),
          makeRunningVm(id: 'v3'),
          makePausedVm(id: 'v4'),
        ]);
        expect(state.running, 2);
        expect(state.stopped, 1);
      });
    });
  });
}
