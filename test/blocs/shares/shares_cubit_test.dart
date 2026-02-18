import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_unraid/blocs/shares/shares_cubit.dart';
import 'package:flutter_unraid/blocs/shares/shares_state.dart';
import 'package:flutter_unraid/data/models/share.dart';
import 'package:flutter_unraid/data/repositories/share_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockShareRepository extends Mock implements ShareRepository {}

void main() {
  late MockShareRepository mockRepository;

  setUp(() {
    mockRepository = MockShareRepository();
  });

  group('SharesCubit', () {
    test('initial state is SharesInitial', () {
      final cubit = SharesCubit(mockRepository);
      expect(cubit.state, const SharesInitial());
      cubit.close();
    });

    group('load', () {
      final mockShares = [
        const Share(
          name: 'appdata',
          comment: 'Application data',
          free: '50 GB',
          size: '100 GB',
        ),
        const Share(
          name: 'media',
          comment: 'Media files',
          free: '1 TB',
          size: '5 TB',
        ),
      ];

      blocTest<SharesCubit, SharesState>(
        'emits [SharesLoading, SharesLoaded] when load succeeds',
        build: () {
          when(() => mockRepository.getShares())
              .thenAnswer((_) async => mockShares);
          return SharesCubit(mockRepository);
        },
        act: (cubit) => cubit.load(),
        expect: () => [
          const SharesLoading(),
          SharesLoaded(mockShares),
        ],
        verify: (_) {
          verify(() => mockRepository.getShares()).called(1);
        },
      );

      blocTest<SharesCubit, SharesState>(
        'emits [SharesLoading, SharesLoaded] with empty list when no shares',
        build: () {
          when(() => mockRepository.getShares()).thenAnswer((_) async => []);
          return SharesCubit(mockRepository);
        },
        act: (cubit) => cubit.load(),
        expect: () => [
          const SharesLoading(),
          const SharesLoaded([]),
        ],
      );

      blocTest<SharesCubit, SharesState>(
        'emits [SharesLoading, SharesError] when load fails',
        build: () {
          when(() => mockRepository.getShares())
              .thenThrow(Exception('Network error'));
          return SharesCubit(mockRepository);
        },
        act: (cubit) => cubit.load(),
        expect: () => [
          const SharesLoading(),
          const SharesError('Unexpected error during loading shares.'),
        ],
      );
    });

    group('refresh', () {
      blocTest<SharesCubit, SharesState>(
        'calls load',
        build: () {
          when(() => mockRepository.getShares()).thenAnswer((_) async => []);
          return SharesCubit(mockRepository);
        },
        act: (cubit) => cubit.refresh(),
        expect: () => [
          const SharesLoading(),
          const SharesLoaded([]),
        ],
        verify: (_) {
          verify(() => mockRepository.getShares()).called(1);
        },
      );
    });
  });
}
