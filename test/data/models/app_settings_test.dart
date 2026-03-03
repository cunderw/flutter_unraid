import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_unraid/data/models/app_settings.dart';

void main() {
  group('AppSettings', () {
    test('has correct default values', () {
      const settings = AppSettings();
      expect(settings.openLinksExternally, false);
      expect(settings.themeMode, ThemeMode.system);
    });

    test('supports value equality', () {
      const a = AppSettings(openLinksExternally: true);
      const b = AppSettings(openLinksExternally: true);
      expect(a, b);
    });

    test('different values are not equal', () {
      const a = AppSettings(openLinksExternally: true);
      const b = AppSettings(openLinksExternally: false);
      expect(a, isNot(b));
    });

    test('different themeMode values are not equal', () {
      const a = AppSettings(themeMode: ThemeMode.dark);
      const b = AppSettings(themeMode: ThemeMode.light);
      expect(a, isNot(b));
    });

    test('copyWith creates copy with updated values', () {
      const original = AppSettings(openLinksExternally: false);
      final updated = original.copyWith(openLinksExternally: true);

      expect(updated.openLinksExternally, true);
      expect(original.openLinksExternally, false);
    });

    test('copyWith updates themeMode', () {
      const original = AppSettings(themeMode: ThemeMode.system);
      final updated = original.copyWith(themeMode: ThemeMode.dark);

      expect(updated.themeMode, ThemeMode.dark);
      expect(original.themeMode, ThemeMode.system);
    });

    test('copyWith with no arguments returns equal instance', () {
      const original = AppSettings(openLinksExternally: true);
      final copy = original.copyWith();

      expect(copy, original);
    });

    test('props contains openLinksExternally and themeMode', () {
      const settings = AppSettings(
        openLinksExternally: true,
        themeMode: ThemeMode.dark,
      );
      expect(settings.props, [true, ThemeMode.dark]);
    });
  });
}
