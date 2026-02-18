import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_unraid/blocs/shares/shares_cubit.dart';
import 'package:flutter_unraid/blocs/shares/shares_state.dart';

import '../../helpers/factories.dart';
import '../../helpers/mocks.dart';

void main() {
  late MockShareRepository mockRepo;

  setUp(() {
    mockRepo = MockShareRepository();
  });

  SharesCubit buildCubit() => SharesCubit(mockRepo);

  group('SharesCubit', () {
    test('initial state is SharesInitial', () {
      expect(buildCubit().state, const SharesInitial());
    });

    group('load', () {
      blocTest<SharesCubit, SharesState>(
        'emits [SharesLoading, SharesLoaded] on success',
        build: () {
          when(() => mockRepo.getShares()).thenAnswer(
            (_) async => [
              makeShare(id: 'share-1', name: 'appdata'),
              makeShare(id: 'share-2', name: 'media'),
            ],
          );
          return buildCubit();
        },
        act: (cubit) => cubit.load(),
        expect: () => [
          const SharesLoading(),
          isA<SharesLoaded>().having((s) => s.shares.length, 'share count', 2),
        ],
      );

      blocTest<SharesCubit, SharesState>(
        'emits [SharesLoading, SharesLoaded] with empty list',
        build: () {
          when(() => mockRepo.getShares()).thenAnswer((_) async => []);
          return buildCubit();
        },
        act: (cubit) => cubit.load(),
        expect: () => [
          const SharesLoading(),
          isA<SharesLoaded>().having((s) => s.shares.length, 'share count', 0),
        ],
      );

      blocTest<SharesCubit, SharesState>(
        'emits [SharesLoading, SharesError] on failure',
        build: () {
          when(() => mockRepo.getShares()).thenThrow(Exception('fail'));
          return buildCubit();
        },
        act: (cubit) => cubit.load(),
        expect: () => [const SharesLoading(), isA<SharesError>()],
      );
    });

    group('refresh', () {
      blocTest<SharesCubit, SharesState>(
        'delegates to load',
        build: () {
          when(() => mockRepo.getShares()).thenAnswer((_) async => []);
          return buildCubit();
        },
        act: (cubit) => cubit.refresh(),
        expect: () => [const SharesLoading(), isA<SharesLoaded>()],
      );
    });
  });
}
