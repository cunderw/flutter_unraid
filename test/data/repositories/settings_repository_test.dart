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

      final settings = repository.getSettings();

      expect(settings, const AppSettings());
      expect(settings.openLinksExternally, false);
    });

    test('returns settings with openLinksExternally=true when stored', () {
      when(
        () => mockPrefs.getBool(AppConstants.keyOpenLinksExternally),
      ).thenReturn(true);

      final settings = repository.getSettings();

      expect(settings.openLinksExternally, true);
    });

    test('returns settings with openLinksExternally=false when stored', () {
      when(
        () => mockPrefs.getBool(AppConstants.keyOpenLinksExternally),
      ).thenReturn(false);

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
}
