import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_unraid/blocs/settings/settings_state.dart';
import 'package:flutter_unraid/data/repositories/settings_repository.dart';
import 'package:flutter_unraid/utils/app_exception.dart';
import 'package:flutter_unraid/utils/log.dart';

class SettingsCubit extends Cubit<SettingsState> {
  static const _tag = 'SettingsCubit';
  final SettingsRepository _repository;

  SettingsCubit(this._repository) : super(const SettingsInitial());

  void loadSettings() {
    emit(const SettingsLoading());
    try {
      Log.d('Loading settings', tag: _tag);
      final settings = _repository.getSettings();
      emit(SettingsLoaded(settings));
    } catch (e, st) {
      final exception = AppException.from(
        e,
        operation: 'loading settings',
        stackTrace: st,
      );
      Log.e('Failed to load settings', tag: _tag, error: e, stackTrace: st);
      emit(SettingsError(exception.message));
    }
  }

  Future<void> setOpenLinksExternally(bool value) async {
    final currentState = state;
    try {
      Log.i('Setting openLinksExternally=$value', tag: _tag);
      await _repository.setOpenLinksExternally(value);
      if (currentState is SettingsLoaded) {
        emit(
          SettingsLoaded(
            currentState.settings.copyWith(openLinksExternally: value),
          ),
        );
      } else {
        loadSettings();
      }
    } catch (e, st) {
      final exception = AppException.from(
        e,
        operation: 'updating settings',
        stackTrace: st,
      );
      Log.e(
        'Failed to update openLinksExternally',
        tag: _tag,
        error: e,
        stackTrace: st,
      );
      if (currentState is SettingsLoaded) {
        // Re-emit current state — the setting wasn't saved
        emit(SettingsLoaded(currentState.settings));
      } else {
        emit(SettingsError(exception.message));
      }
    }
  }
}
