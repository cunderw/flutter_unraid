import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_unraid/data/models/app_settings.dart';
import 'package:flutter_unraid/data/repositories/settings_repository.dart';
import 'package:flutter_unraid/utils/constants.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockSharedPreferences mockPrefs;
  late SettingsRepository repository;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    repository = SettingsRepository(mockPrefs);
  });

  group('getSettings', () {
    test('returns default settings when no preferences are stored', () {
      when(
        () => mockPrefs.getBool(AppConstants.keyOpenLinksExternally),
      ).thenReturn(null);
      when(
        () => mockPrefs.getString(AppConstants.keyThemeMode),
      ).thenReturn(null);

      final settings = repository.getSettings();

      expect(settings, const AppSettings());
      expect(settings.openLinksExternally, false);
      expect(settings.themeMode, ThemeMode.system);
    });

    test('returns settings with openLinksExternally=true when stored', () {
      when(
        () => mockPrefs.getBool(AppConstants.keyOpenLinksExternally),
      ).thenReturn(true);
      when(
        () => mockPrefs.getString(AppConstants.keyThemeMode),
      ).thenReturn(null);

      final settings = repository.getSettings();

      expect(settings.openLinksExternally, true);
    });

    test('returns settings with openLinksExternally=false when stored', () {
      when(
        () => mockPrefs.getBool(AppConstants.keyOpenLinksExternally),
      ).thenReturn(false);
      when(
        () => mockPrefs.getString(AppConstants.keyThemeMode),
      ).thenReturn(null);

      final settings = repository.getSettings();

      expect(settings.openLinksExternally, false);
    });
  });

  group('setOpenLinksExternally', () {
    test('stores true value in shared preferences', () async {
      when(
        () => mockPrefs.setBool(AppConstants.keyOpenLinksExternally, true),
      ).thenAnswer((_) async => true);

      await repository.setOpenLinksExternally(true);

      verify(
        () => mockPrefs.setBool(AppConstants.keyOpenLinksExternally, true),
      ).called(1);
    });

    test('stores false value in shared preferences', () async {
      when(
        () => mockPrefs.setBool(AppConstants.keyOpenLinksExternally, false),
      ).thenAnswer((_) async => true);

      await repository.setOpenLinksExternally(false);

      verify(
        () => mockPrefs.setBool(AppConstants.keyOpenLinksExternally, false),
      ).called(1);
    });
  });

  group('getSettings - themeMode', () {
    setUp(() {
      when(
        () => mockPrefs.getBool(AppConstants.keyOpenLinksExternally),
      ).thenReturn(false);
    });

    test('returns ThemeMode.system when no preference stored', () {
      when(
        () => mockPrefs.getString(AppConstants.keyThemeMode),
      ).thenReturn(null);

      final settings = repository.getSettings();

      expect(settings.themeMode, ThemeMode.system);
    });

    test('returns ThemeMode.dark when "dark" stored', () {
      when(
        () => mockPrefs.getString(AppConstants.keyThemeMode),
      ).thenReturn('dark');

      final settings = repository.getSettings();

      expect(settings.themeMode, ThemeMode.dark);
    });

    test('returns ThemeMode.light when "light" stored', () {
      when(
        () => mockPrefs.getString(AppConstants.keyThemeMode),
      ).thenReturn('light');

      final settings = repository.getSettings();

      expect(settings.themeMode, ThemeMode.light);
    });

    test('returns ThemeMode.system for unrecognized value', () {
      when(
        () => mockPrefs.getString(AppConstants.keyThemeMode),
      ).thenReturn('invalid');

      final settings = repository.getSettings();

      expect(settings.themeMode, ThemeMode.system);
    });
  });

  group('setThemeMode', () {
    test('stores "dark" in shared preferences for ThemeMode.dark', () async {
      when(
        () => mockPrefs.setString(AppConstants.keyThemeMode, 'dark'),
      ).thenAnswer((_) async => true);

      await repository.setThemeMode(ThemeMode.dark);

      verify(
        () => mockPrefs.setString(AppConstants.keyThemeMode, 'dark'),
      ).called(1);
    });

    test('stores "light" in shared preferences for ThemeMode.light', () async {
      when(
        () => mockPrefs.setString(AppConstants.keyThemeMode, 'light'),
      ).thenAnswer((_) async => true);

      await repository.setThemeMode(ThemeMode.light);

      verify(
        () => mockPrefs.setString(AppConstants.keyThemeMode, 'light'),
      ).called(1);
    });

    test(
      'stores "system" in shared preferences for ThemeMode.system',
      () async {
        when(
          () => mockPrefs.setString(AppConstants.keyThemeMode, 'system'),
        ).thenAnswer((_) async => true);

        await repository.setThemeMode(ThemeMode.system);

        verify(
          () => mockPrefs.setString(AppConstants.keyThemeMode, 'system'),
        ).called(1);
      },
    );
  });
}
