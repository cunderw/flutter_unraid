import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_unraid/blocs/auth/auth_state.dart';
import 'package:flutter_unraid/blocs/settings/settings_state.dart';
import 'package:flutter_unraid/ui/screens/settings/settings_screen.dart';

import '../../../helpers/factories.dart';
import '../../../helpers/mocks.dart';
import '../../../helpers/pump_helpers.dart';

void main() {
  late MockAuthCubit mockAuthCubit;
  late MockSettingsCubit mockSettingsCubit;

  setUpAll(() {
    registerFallbackValue(ThemeMode.system);
  });

  setUp(() {
    mockAuthCubit = MockAuthCubit();
    mockSettingsCubit = MockSettingsCubit();
    when(() => mockAuthCubit.logout()).thenAnswer((_) async {});
    when(
      () => mockSettingsCubit.setOpenLinksExternally(any()),
    ).thenAnswer((_) async {});
    when(() => mockSettingsCubit.setThemeMode(any())).thenAnswer((_) async {});
  });

  Future<void> pumpSettingsScreen(
    WidgetTester tester, {
    required SettingsState settingsState,
  }) async {
    when(() => mockSettingsCubit.state).thenReturn(settingsState);
    when(
      () => mockAuthCubit.state,
    ).thenReturn(const Authenticated(serverUrl: 'http://test'));
    await tester.pumpAppWithBlocs(
      const SettingsScreen(),
      authCubit: mockAuthCubit,
      authState: const Authenticated(serverUrl: 'http://test'),
      settingsCubit: mockSettingsCubit,
      settingsState: settingsState,
    );
  }

  group('SettingsScreen', () {
    testWidgets('shows loading indicator in Loading state', (tester) async {
      await pumpSettingsScreen(tester, settingsState: const SettingsLoading());
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows loading indicator in Initial state', (tester) async {
      await pumpSettingsScreen(tester, settingsState: const SettingsInitial());
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message in Error state', (tester) async {
      await pumpSettingsScreen(
        tester,
        settingsState: const SettingsError('Something went wrong'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('shows settings in Loaded state', (tester) async {
      await pumpSettingsScreen(
        tester,
        settingsState: SettingsLoaded(makeAppSettings()),
      );
      await tester.pumpAndSettle();
      expect(find.text('Open links externally'), findsOneWidget);
      expect(find.text('Disconnect'), findsOneWidget);
    });

    testWidgets('switch reflects openLinksExternally=false', (tester) async {
      await pumpSettingsScreen(
        tester,
        settingsState: SettingsLoaded(
          makeAppSettings(openLinksExternally: false),
        ),
      );
      await tester.pumpAndSettle();

      final switchWidget = tester.widget<SwitchListTile>(
        find.byType(SwitchListTile),
      );
      expect(switchWidget.value, false);
    });

    testWidgets('switch reflects openLinksExternally=true', (tester) async {
      await pumpSettingsScreen(
        tester,
        settingsState: SettingsLoaded(
          makeAppSettings(openLinksExternally: true),
        ),
      );
      await tester.pumpAndSettle();

      final switchWidget = tester.widget<SwitchListTile>(
        find.byType(SwitchListTile),
      );
      expect(switchWidget.value, true);
    });

    testWidgets('toggling switch calls setOpenLinksExternally', (tester) async {
      await pumpSettingsScreen(
        tester,
        settingsState: SettingsLoaded(
          makeAppSettings(openLinksExternally: false),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();

      verify(() => mockSettingsCubit.setOpenLinksExternally(true)).called(1);
    });

    testWidgets('tapping Disconnect shows confirmation dialog', (tester) async {
      await pumpSettingsScreen(
        tester,
        settingsState: SettingsLoaded(makeAppSettings()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Disconnect'));
      await tester.pumpAndSettle();

      expect(
        find.text('Are you sure you want to disconnect from the server?'),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('cancel button dismisses confirmation dialog', (tester) async {
      await pumpSettingsScreen(
        tester,
        settingsState: SettingsLoaded(makeAppSettings()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Disconnect'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(
        find.text('Are you sure you want to disconnect from the server?'),
        findsNothing,
      );
    });

    testWidgets('Settings title is shown in app bar', (tester) async {
      await pumpSettingsScreen(
        tester,
        settingsState: SettingsLoaded(makeAppSettings()),
      );
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('shows section headers', (tester) async {
      await pumpSettingsScreen(
        tester,
        settingsState: SettingsLoaded(makeAppSettings()),
      );
      await tester.pumpAndSettle();
      expect(find.text('General'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);
    });

    testWidgets('shows theme mode radio buttons in Loaded state', (
      tester,
    ) async {
      await pumpSettingsScreen(
        tester,
        settingsState: SettingsLoaded(makeAppSettings()),
      );
      await tester.pumpAndSettle();
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);
    });

    testWidgets('system radio is selected by default', (tester) async {
      await pumpSettingsScreen(
        tester,
        settingsState: SettingsLoaded(
          makeAppSettings(themeMode: ThemeMode.system),
        ),
      );
      await tester.pumpAndSettle();

      final radioGroup = tester.widget<RadioGroup<ThemeMode>>(
        find.byType(RadioGroup<ThemeMode>),
      );
      expect(radioGroup.groupValue, ThemeMode.system);
    });

    testWidgets('dark radio is selected when themeMode is dark', (
      tester,
    ) async {
      await pumpSettingsScreen(
        tester,
        settingsState: SettingsLoaded(
          makeAppSettings(themeMode: ThemeMode.dark),
        ),
      );
      await tester.pumpAndSettle();

      final radioGroup = tester.widget<RadioGroup<ThemeMode>>(
        find.byType(RadioGroup<ThemeMode>),
      );
      expect(radioGroup.groupValue, ThemeMode.dark);
    });

    testWidgets('light radio is selected when themeMode is light', (
      tester,
    ) async {
      await pumpSettingsScreen(
        tester,
        settingsState: SettingsLoaded(
          makeAppSettings(themeMode: ThemeMode.light),
        ),
      );
      await tester.pumpAndSettle();

      final radioGroup = tester.widget<RadioGroup<ThemeMode>>(
        find.byType(RadioGroup<ThemeMode>),
      );
      expect(radioGroup.groupValue, ThemeMode.light);
    });

    testWidgets('tapping Light radio calls setThemeMode with light', (
      tester,
    ) async {
      await pumpSettingsScreen(
        tester,
        settingsState: SettingsLoaded(
          makeAppSettings(themeMode: ThemeMode.dark),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(RadioListTile<ThemeMode>, 'Light'));
      await tester.pumpAndSettle();

      verify(() => mockSettingsCubit.setThemeMode(ThemeMode.light)).called(1);
    });

    testWidgets('tapping Dark radio calls setThemeMode with dark', (
      tester,
    ) async {
      await pumpSettingsScreen(
        tester,
        settingsState: SettingsLoaded(
          makeAppSettings(themeMode: ThemeMode.system),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(RadioListTile<ThemeMode>, 'Dark'));
      await tester.pumpAndSettle();

      verify(() => mockSettingsCubit.setThemeMode(ThemeMode.dark)).called(1);
    });

    testWidgets('tapping System radio calls setThemeMode with system', (
      tester,
    ) async {
      await pumpSettingsScreen(
        tester,
        settingsState: SettingsLoaded(
          makeAppSettings(themeMode: ThemeMode.dark),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(RadioListTile<ThemeMode>, 'System'));
      await tester.pumpAndSettle();

      verify(() => mockSettingsCubit.setThemeMode(ThemeMode.system)).called(1);
    });
  });
}
