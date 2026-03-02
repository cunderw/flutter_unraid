import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_unraid/ui/screens/home/tabs/main_tab/cubit/system_logs_cubit.dart';
import 'package:flutter_unraid/ui/screens/home/tabs/main_tab/cubit/system_logs_state.dart';
import 'package:flutter_unraid/ui/screens/home/tabs/main_tab/system_logs_section.dart';
import 'package:flutter_unraid/ui/widgets/feedback/inline_error.dart';

import '../../../../../helpers/mocks.dart';
import '../../../../../helpers/pump_helpers.dart';

void main() {
  late MockSystemLogsCubit mockLogsCubit;

  setUp(() {
    mockLogsCubit = MockSystemLogsCubit();
    // Stub async methods so taps don't throw Null/Future<void> errors
    when(
      () => mockLogsCubit.load(lines: any(named: 'lines')),
    ).thenAnswer((_) async {});
    when(
      () => mockLogsCubit.refresh(lines: any(named: 'lines')),
    ).thenAnswer((_) async {});
  });

  /// Helper to pump the widget with a stubbed SystemLogsCubit.
  Future<void> pumpLogsSection(
    WidgetTester tester, {
    required SystemLogsState state,
  }) async {
    when(() => mockLogsCubit.state).thenReturn(state);
    await tester.pumpAppWithBlocs(
      const SystemLogsSection(),
      providers: [BlocProvider<SystemLogsCubit>.value(value: mockLogsCubit)],
    );
  }

  group('SystemLogsSection', () {
    testWidgets('displays System Logs title', (tester) async {
      await pumpLogsSection(tester, state: const SystemLogsInitial());
      await tester.pumpAndSettle();

      expect(find.text('System Logs'), findsOneWidget);
    });

    testWidgets('displays loading indicator when SystemLogsLoading', (
      tester,
    ) async {
      await pumpLogsSection(tester, state: const SystemLogsLoading());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays refresh button when logs are loaded', (tester) async {
      await pumpLogsSection(tester, state: const SystemLogsLoaded([]));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('displays error message when SystemLogsError', (tester) async {
      await pumpLogsSection(
        tester,
        state: const SystemLogsError('Failed to load logs'),
      );
      await tester.pumpAndSettle();

      // Expand the section
      await tester.tap(find.text('System Logs'));
      await tester.pumpAndSettle();

      expect(find.byType(InlineError), findsOneWidget);
      expect(find.text('Failed to load logs'), findsOneWidget);
    });

    testWidgets('displays no logs message when logs list is empty', (
      tester,
    ) async {
      await pumpLogsSection(tester, state: const SystemLogsLoaded([]));
      await tester.pumpAndSettle();

      // Expand the section
      await tester.tap(find.text('System Logs'));
      await tester.pumpAndSettle();

      expect(find.text('No logs available.'), findsOneWidget);
    });

    testWidgets('displays log lines when logs are available', (tester) async {
      final logLines = [
        'Jan  1 12:00:00 tower kernel: System log line 1',
        'Jan  1 12:00:01 tower kernel: System log line 2',
      ];

      await pumpLogsSection(tester, state: SystemLogsLoaded(logLines));
      await tester.pumpAndSettle();

      // Expand the section
      await tester.tap(find.text('System Logs'));
      await tester.pumpAndSettle();

      expect(
        find.text('Jan  1 12:00:00 tower kernel: System log line 1'),
        findsOneWidget,
      );
      expect(
        find.text('Jan  1 12:00:01 tower kernel: System log line 2'),
        findsOneWidget,
      );
    });

    testWidgets('displays in a card', (tester) async {
      await pumpLogsSection(tester, state: const SystemLogsInitial());
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('shows expand/collapse icon', (tester) async {
      await pumpLogsSection(tester, state: const SystemLogsInitial());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);

      // Tap to expand
      await tester.tap(find.text('System Logs'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.keyboard_arrow_up), findsOneWidget);
    });

    testWidgets('shows View All button when logs are expanded', (tester) async {
      final logLines = ['Jan  1 12:00:00 tower kernel: Log line 1'];

      await pumpLogsSection(tester, state: SystemLogsLoaded(logLines));
      await tester.pumpAndSettle();

      // Expand the section
      await tester.tap(find.text('System Logs'));
      await tester.pumpAndSettle();

      expect(find.text('View All'), findsOneWidget);
    });

    testWidgets('calls load with tail=10 when first expanded', (tester) async {
      await pumpLogsSection(tester, state: const SystemLogsInitial());
      await tester.pumpAndSettle();

      // Tap to expand
      await tester.tap(find.text('System Logs'));
      await tester.pumpAndSettle();

      verify(() => mockLogsCubit.load(lines: 10)).called(1);
    });

    testWidgets('toggles between View All and Show Last 10', (tester) async {
      final logLines = ['Jan  1 12:00:00 tower kernel: Log line 1'];

      await pumpLogsSection(tester, state: SystemLogsLoaded(logLines));
      await tester.pumpAndSettle();

      // Expand the section
      await tester.tap(find.text('System Logs'));
      await tester.pumpAndSettle();

      expect(find.text('View All'), findsOneWidget);

      // Tap View All button
      await tester.tap(find.text('View All'));
      await tester.pumpAndSettle();

      verify(() => mockLogsCubit.load(lines: null)).called(1);
    });
  });
}
