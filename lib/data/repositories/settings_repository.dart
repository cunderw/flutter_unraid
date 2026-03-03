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
    );
  }

  Future<void> setOpenLinksExternally(bool value) async {
    Log.i('Setting openLinksExternally=$value', tag: _tag);
    await _prefs.setBool(AppConstants.keyOpenLinksExternally, value);
  }
}
