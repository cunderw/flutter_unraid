import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_unraid/ui/screens/home/tabs/main_tab/cubit/system_logs_cubit.dart';
import 'package:flutter_unraid/ui/screens/home/tabs/main_tab/cubit/system_logs_state.dart';

import '../../../../../../helpers/mocks.dart';

void main() {
  late MockSystemRepository mockRepo;

  setUp(() {
    mockRepo = MockSystemRepository();
  });

  SystemLogsCubit buildCubit() => SystemLogsCubit(mockRepo);

  group('SystemLogsCubit', () {
    test('initial state is SystemLogsInitial', () {
      expect(buildCubit().state, const SystemLogsInitial());
    });

    group('load', () {
      final logLines = [
        'Jan  1 00:00:00 tower kernel: System log line 1',
        'Jan  1 00:00:01 tower kernel: System log line 2',
      ];

      blocTest<SystemLogsCubit, SystemLogsState>(
        'emits [SystemLogsLoading, SystemLogsLoaded] on success',
        build: () {
          when(
            () => mockRepo.getSystemLogs(lines: any(named: 'lines')),
          ).thenAnswer((_) async => logLines);
          return buildCubit();
        },
        act: (cubit) => cubit.load(),
        expect: () => [const SystemLogsLoading(), SystemLogsLoaded(logLines)],
        verify: (_) {
          verify(() => mockRepo.getSystemLogs(lines: null)).called(1);
        },
      );

      blocTest<SystemLogsCubit, SystemLogsState>(
        'emits [SystemLogsLoading, SystemLogsLoaded] with lines parameter',
        build: () {
          when(
            () => mockRepo.getSystemLogs(lines: any(named: 'lines')),
          ).thenAnswer((_) async => logLines.take(1).toList());
          return buildCubit();
        },
        act: (cubit) => cubit.load(lines: 10),
        expect: () => [
          const SystemLogsLoading(),
          isA<SystemLogsLoaded>().having(
            (s) => s.lines.length,
            'lines count',
            1,
          ),
        ],
        verify: (_) {
          verify(() => mockRepo.getSystemLogs(lines: 10)).called(1);
        },
      );

      blocTest<SystemLogsCubit, SystemLogsState>(
        'emits [SystemLogsLoading, SystemLogsLoaded] with empty logs',
        build: () {
          when(
            () => mockRepo.getSystemLogs(lines: any(named: 'lines')),
          ).thenAnswer((_) async => <String>[]);
          return buildCubit();
        },
        act: (cubit) => cubit.load(),
        expect: () => [const SystemLogsLoading(), const SystemLogsLoaded([])],
      );

      blocTest<SystemLogsCubit, SystemLogsState>(
        'emits [SystemLogsLoading, SystemLogsError] on failure',
        build: () {
          when(
            () => mockRepo.getSystemLogs(lines: any(named: 'lines')),
          ).thenThrow(Exception('fail'));
          return buildCubit();
        },
        act: (cubit) => cubit.load(),
        expect: () => [const SystemLogsLoading(), isA<SystemLogsError>()],
      );
    });

    group('refresh', () {
      blocTest<SystemLogsCubit, SystemLogsState>(
        'delegates to load with lines parameter',
        build: () {
          when(
            () => mockRepo.getSystemLogs(lines: any(named: 'lines')),
          ).thenAnswer((_) async => <String>[]);
          return buildCubit();
        },
        act: (cubit) => cubit.refresh(lines: 10),
        expect: () => [const SystemLogsLoading(), const SystemLogsLoaded([])],
        verify: (_) {
          verify(() => mockRepo.getSystemLogs(lines: 10)).called(1);
        },
      );
    });
  });
}
