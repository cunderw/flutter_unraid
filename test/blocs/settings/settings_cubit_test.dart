import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_unraid/blocs/settings/settings_cubit.dart';
import 'package:flutter_unraid/blocs/settings/settings_state.dart';

import '../../helpers/factories.dart';
import '../../helpers/mocks.dart';

void main() {
  late MockSettingsRepository mockRepository;

  SettingsCubit buildCubit() => SettingsCubit(mockRepository);

  setUp(() {
    mockRepository = MockSettingsRepository();
  });

  group('loadSettings', () {
    blocTest<SettingsCubit, SettingsState>(
      'emits [Loading, Loaded] on success',
      setUp: () {
        when(() => mockRepository.getSettings()).thenReturn(makeAppSettings());
      },
      build: buildCubit,
      act: (cubit) => cubit.loadSettings(),
      expect: () => [
        const SettingsLoading(),
        SettingsLoaded(makeAppSettings()),
      ],
      verify: (_) {
        verify(() => mockRepository.getSettings()).called(1);
      },
    );

    blocTest<SettingsCubit, SettingsState>(
      'emits [Loading, Loaded] with openLinksExternally=true',
      setUp: () {
        when(
          () => mockRepository.getSettings(),
        ).thenReturn(makeAppSettings(openLinksExternally: true));
      },
      build: buildCubit,
      act: (cubit) => cubit.loadSettings(),
      expect: () => [
        const SettingsLoading(),
        SettingsLoaded(makeAppSettings(openLinksExternally: true)),
      ],
    );

    blocTest<SettingsCubit, SettingsState>(
      'emits [Loading, Error] on failure',
      setUp: () {
        when(() => mockRepository.getSettings()).thenThrow(Exception('fail'));
      },
      build: buildCubit,
      act: (cubit) => cubit.loadSettings(),
      expect: () => [const SettingsLoading(), isA<SettingsError>()],
    );
  });

  group('setOpenLinksExternally', () {
    blocTest<SettingsCubit, SettingsState>(
      'emits updated Loaded state when toggling to true',
      setUp: () {
        when(
          () => mockRepository.setOpenLinksExternally(true),
        ).thenAnswer((_) async {});
      },
      build: buildCubit,
      seed: () => SettingsLoaded(makeAppSettings()),
      act: (cubit) => cubit.setOpenLinksExternally(true),
      expect: () => [
        SettingsLoaded(makeAppSettings(openLinksExternally: true)),
      ],
      verify: (_) {
        verify(() => mockRepository.setOpenLinksExternally(true)).called(1);
      },
    );

    blocTest<SettingsCubit, SettingsState>(
      'emits updated Loaded state when toggling to false',
      setUp: () {
        when(
          () => mockRepository.setOpenLinksExternally(false),
        ).thenAnswer((_) async {});
      },
      build: buildCubit,
      seed: () => SettingsLoaded(makeAppSettings(openLinksExternally: true)),
      act: (cubit) => cubit.setOpenLinksExternally(false),
      expect: () => [
        SettingsLoaded(makeAppSettings(openLinksExternally: false)),
      ],
    );

    blocTest<SettingsCubit, SettingsState>(
      'does not emit new state on failure when loaded (state unchanged)',
      setUp: () {
        when(
          () => mockRepository.setOpenLinksExternally(true),
        ).thenThrow(Exception('fail'));
      },
      build: buildCubit,
      seed: () => SettingsLoaded(makeAppSettings()),
      act: (cubit) => cubit.setOpenLinksExternally(true),
      expect: () => <SettingsState>[],
    );

    blocTest<SettingsCubit, SettingsState>(
      'emits Error on failure when not loaded',
      setUp: () {
        when(
          () => mockRepository.setOpenLinksExternally(true),
        ).thenThrow(Exception('fail'));
      },
      build: buildCubit,
      act: (cubit) => cubit.setOpenLinksExternally(true),
      expect: () => [isA<SettingsError>()],
    );
  });
}
