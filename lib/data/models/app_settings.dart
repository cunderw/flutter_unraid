import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class AppSettings extends Equatable {
  final bool openLinksExternally;
  final ThemeMode themeMode;

  const AppSettings({
    this.openLinksExternally = false,
    this.themeMode = ThemeMode.system,
  });

  AppSettings copyWith({bool? openLinksExternally, ThemeMode? themeMode}) {
    return AppSettings(
      openLinksExternally: openLinksExternally ?? this.openLinksExternally,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  List<Object?> get props => [openLinksExternally, themeMode];
}
