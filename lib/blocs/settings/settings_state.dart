import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'package:flutter_unraid/data/models/app_settings.dart';

sealed class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

final class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

final class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

final class SettingsLoaded extends SettingsState {
  final AppSettings settings;

  const SettingsLoaded(this.settings);

  bool get openLinksExternally => settings.openLinksExternally;
  ThemeMode get themeMode => settings.themeMode;

  @override
  List<Object?> get props => [settings];
}

final class SettingsError extends SettingsState {
  final String message;

  const SettingsError(this.message);

  @override
  List<Object?> get props => [message];
}
