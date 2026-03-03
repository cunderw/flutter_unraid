import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_unraid/blocs/settings/settings_cubit.dart';
import 'package:flutter_unraid/blocs/settings/settings_state.dart';

import '../../helpers/factories.dart';
import '../../helpers/mocks.dart';

void main() {
  late MockSettingsRepository mockRepository;

  SettingsCubit buildCubit() => SettingsCubit(mockRepository);

  setUpAll(() {
    registerFallbackValue(ThemeMode.system);
  });

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

  group('setThemeMode', () {
    blocTest<SettingsCubit, SettingsState>(
      'emits updated Loaded state when changing to dark',
      setUp: () {
        when(
          () => mockRepository.setThemeMode(ThemeMode.dark),
        ).thenAnswer((_) async {});
      },
      build: buildCubit,
      seed: () => SettingsLoaded(makeAppSettings()),
      act: (cubit) => cubit.setThemeMode(ThemeMode.dark),
      expect: () => [
        SettingsLoaded(makeAppSettings(themeMode: ThemeMode.dark)),
      ],
      verify: (_) {
        verify(() => mockRepository.setThemeMode(ThemeMode.dark)).called(1);
      },
    );

    blocTest<SettingsCubit, SettingsState>(
      'emits updated Loaded state when changing to light',
      setUp: () {
        when(
          () => mockRepository.setThemeMode(ThemeMode.light),
        ).thenAnswer((_) async {});
      },
      build: buildCubit,
      seed: () => SettingsLoaded(makeAppSettings(themeMode: ThemeMode.dark)),
      act: (cubit) => cubit.setThemeMode(ThemeMode.light),
      expect: () => [
        SettingsLoaded(makeAppSettings(themeMode: ThemeMode.light)),
      ],
    );

    blocTest<SettingsCubit, SettingsState>(
      'emits updated Loaded state when changing to system',
      setUp: () {
        when(
          () => mockRepository.setThemeMode(ThemeMode.system),
        ).thenAnswer((_) async {});
      },
      build: buildCubit,
      seed: () => SettingsLoaded(makeAppSettings(themeMode: ThemeMode.dark)),
      act: (cubit) => cubit.setThemeMode(ThemeMode.system),
      expect: () => [
        SettingsLoaded(makeAppSettings(themeMode: ThemeMode.system)),
      ],
    );

    blocTest<SettingsCubit, SettingsState>(
      'does not emit new state on failure when loaded (state unchanged)',
      setUp: () {
        when(
          () => mockRepository.setThemeMode(any()),
        ).thenThrow(Exception('fail'));
      },
      build: buildCubit,
      seed: () => SettingsLoaded(makeAppSettings()),
      act: (cubit) => cubit.setThemeMode(ThemeMode.dark),
      expect: () => <SettingsState>[],
    );

    blocTest<SettingsCubit, SettingsState>(
      'emits Error on failure when not loaded',
      setUp: () {
        when(
          () => mockRepository.setThemeMode(any()),
        ).thenThrow(Exception('fail'));
      },
      build: buildCubit,
      act: (cubit) => cubit.setThemeMode(ThemeMode.dark),
      expect: () => [isA<SettingsError>()],
    );
  });
}
