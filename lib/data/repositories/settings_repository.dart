import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_unraid/data/models/app_settings.dart';
import 'package:flutter_unraid/utils/constants.dart';
import 'package:flutter_unraid/utils/log.dart';

class SettingsRepository {
  static const _tag = 'SettingsRepository';
  final SharedPreferences _prefs;

  SettingsRepository(this._prefs);

  AppSettings getSettings() {
    Log.d('Loading settings', tag: _tag);
    return AppSettings(
      openLinksExternally:
          _prefs.getBool(AppConstants.keyOpenLinksExternally) ?? false,
      themeMode: _parseThemeMode(_prefs.getString(AppConstants.keyThemeMode)),
    );
  }

  Future<void> setOpenLinksExternally(bool value) async {
    Log.i('Setting openLinksExternally=$value', tag: _tag);
    await _prefs.setBool(AppConstants.keyOpenLinksExternally, value);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    Log.i('Setting themeMode=${mode.name}', tag: _tag);
    await _prefs.setString(AppConstants.keyThemeMode, mode.name);
  }

  ThemeMode _parseThemeMode(String? value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }
}
