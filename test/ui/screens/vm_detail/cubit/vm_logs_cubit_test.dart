import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_unraid/ui/screens/vm_detail/cubit/vm_logs_cubit.dart';
import 'package:flutter_unraid/ui/screens/vm_detail/cubit/vm_logs_state.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockVmRepository mockRepo;

  setUp(() {
    mockRepo = MockVmRepository();
  });

  VmLogsCubit buildCubit({String vmId = 'test-vm'}) =>
      VmLogsCubit(mockRepo, vmId: vmId);

  group('VmLogsCubit', () {
    test('initial state is VmLogsInitial', () {
      expect(buildCubit().state, const VmLogsInitial());
    });

    group('load', () {
      final logLines = [
        'Log line 1',
        'Log line 2',
        'Log line 3',
      ];

      blocTest<VmLogsCubit, VmLogsState>(
        'emits [VmLogsLoading, VmLogsLoaded] on success',
        build: () {
          when(
            () => mockRepo.getVmLogs(any(), tail: any(named: 'tail')),
          ).thenAnswer((_) async => logLines);
          return buildCubit(vmId: 'vm-1');
        },
        act: (cubit) => cubit.load(),
        expect: () => [
          const VmLogsLoading(),
          VmLogsLoaded(logLines),
        ],
        verify: (_) {
          verify(() => mockRepo.getVmLogs('vm-1', tail: 100)).called(1);
        },
      );

      blocTest<VmLogsCubit, VmLogsState>(
        'emits [VmLogsLoading, VmLogsLoaded] with empty logs',
        build: () {
          when(
            () => mockRepo.getVmLogs(any(), tail: any(named: 'tail')),
          ).thenAnswer((_) async => []);
          return buildCubit();
        },
        act: (cubit) => cubit.load(),
        expect: () => [
          const VmLogsLoading(),
          const VmLogsLoaded([]),
        ],
      );

      blocTest<VmLogsCubit, VmLogsState>(
        'emits [VmLogsLoading, VmLogsError] on failure',
        build: () {
          when(
            () => mockRepo.getVmLogs(any(), tail: any(named: 'tail')),
          ).thenThrow(Exception('fail'));
          return buildCubit();
        },
        act: (cubit) => cubit.load(),
        expect: () => [const VmLogsLoading(), isA<VmLogsError>()],
      );
    });

    group('refresh', () {
      blocTest<VmLogsCubit, VmLogsState>(
        'delegates to load',
        build: () {
          when(
            () => mockRepo.getVmLogs(any(), tail: any(named: 'tail')),
          ).thenAnswer((_) async => []);
          return buildCubit();
        },
        act: (cubit) => cubit.refresh(),
        expect: () => [
          const VmLogsLoading(),
          const VmLogsLoaded([]),
        ],
      );
    });
  });
}
