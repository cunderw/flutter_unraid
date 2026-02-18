import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_unraid/blocs/auth/auth_state.dart';
import 'package:flutter_unraid/ui/screens/login_screen.dart';

import '../../helpers/mocks.dart';
import '../../helpers/pump_helpers.dart';

void main() {
  late MockAuthCubit mockAuthCubit;

  setUp(() {
    mockAuthCubit = MockAuthCubit();
  });

  group('LoginScreen', () {
    testWidgets('displays login form with all fields', (tester) async {
      await tester.pumpAppWithBlocs(
        const LoginScreen(),
        authCubit: mockAuthCubit,
        authState: const AuthInitial(),
      );
      await tester.pumpAndSettle();

      expect(find.text('Unraid Manager'), findsOneWidget);
      expect(find.text('Connect to your Unraid server'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Server Address'), findsOneWidget);
      expect(find.text('API Key'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Connect'), findsOneWidget);
    });

    testWidgets('displays logo icon', (tester) async {
      await tester.pumpAppWithBlocs(
        const LoginScreen(),
        authCubit: mockAuthCubit,
        authState: const AuthInitial(),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.dns_rounded), findsOneWidget);
    });

    testWidgets('displays hint for API key location', (tester) async {
      await tester.pumpAppWithBlocs(
        const LoginScreen(),
        authCubit: mockAuthCubit,
        authState: const AuthInitial(),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Find your API key in Unraid Settings → Management Access → API.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('has visibility toggle for API key field', (tester) async {
      await tester.pumpAppWithBlocs(
        const LoginScreen(),
        authCubit: mockAuthCubit,
        authState: const AuthInitial(),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('server address field has URL validation hint', (tester) async {
      await tester.pumpAppWithBlocs(
        const LoginScreen(),
        authCubit: mockAuthCubit,
        authState: const AuthInitial(),
      );
      await tester.pumpAndSettle();

      expect(find.text('https://your-unraid-server'), findsOneWidget);
    });

    testWidgets('displays error message when AuthError state', (tester) async {
      await tester.pumpAppWithBlocs(
        const LoginScreen(),
        authCubit: mockAuthCubit,
        authState: const AuthError('Invalid credentials'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Invalid credentials'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('shows loading indicator when AuthLoading state', (
      tester,
    ) async {
      await tester.pumpAppWithBlocs(
        const LoginScreen(),
        authCubit: mockAuthCubit,
        authState: const AuthLoading(),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('connect button is disabled during loading', (tester) async {
      await tester.pumpAppWithBlocs(
        const LoginScreen(),
        authCubit: mockAuthCubit,
        authState: const AuthLoading(),
      );
      await tester.pump();

      // During loading the button text is replaced with a spinner,
      // so locate the ElevatedButton by type.
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });
  });
}
