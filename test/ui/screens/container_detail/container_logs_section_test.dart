import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_unraid/ui/screens/container_detail/cubit/container_logs_cubit.dart';
import 'package:flutter_unraid/ui/screens/container_detail/cubit/container_logs_state.dart';
import 'package:flutter_unraid/ui/screens/container_detail/container_logs_section.dart';
import 'package:flutter_unraid/ui/widgets/feedback/inline_error.dart';

import '../../../helpers/mocks.dart';
import '../../../helpers/pump_helpers.dart';

void main() {
  late MockContainerLogsCubit mockLogsCubit;

  setUp(() {
    mockLogsCubit = MockContainerLogsCubit();
    // Stub async methods so taps don't throw Null/Future<void> errors
    when(() => mockLogsCubit.load()).thenAnswer((_) async {});
    when(() => mockLogsCubit.refresh()).thenAnswer((_) async {});
  });

  /// Helper to pump the widget with a stubbed ContainerLogsCubit.
  Future<void> pumpLogsSection(
    WidgetTester tester, {
    required ContainerLogsState state,
  }) async {
    when(() => mockLogsCubit.state).thenReturn(state);
    await tester.pumpAppWithBlocs(
      const ContainerLogsSection(containerId: 'c1'),
      providers: [BlocProvider<ContainerLogsCubit>.value(value: mockLogsCubit)],
    );
  }

  group('ContainerLogsSection', () {
    testWidgets('displays Logs title', (tester) async {
      await pumpLogsSection(tester, state: const ContainerLogsInitial());
      await tester.pumpAndSettle();

      expect(find.text('Logs'), findsOneWidget);
    });

    testWidgets('displays loading indicator when ContainerLogsLoading', (
      tester,
    ) async {
      await pumpLogsSection(tester, state: const ContainerLogsLoading());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays refresh button when logs are loaded', (tester) async {
      await pumpLogsSection(tester, state: const ContainerLogsLoaded([]));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('displays error message when ContainerLogsError', (
      tester,
    ) async {
      await pumpLogsSection(
        tester,
        state: const ContainerLogsError('Failed to load logs'),
      );
      await tester.pumpAndSettle();

      // Expand the section
      await tester.tap(find.text('Logs'));
      await tester.pumpAndSettle();

      expect(find.byType(InlineError), findsOneWidget);
      expect(find.text('Failed to load logs'), findsOneWidget);
    });

    testWidgets('displays no logs message when logs list is empty', (
      tester,
    ) async {
      await pumpLogsSection(tester, state: const ContainerLogsLoaded([]));
      await tester.pumpAndSettle();

      // Expand the section
      await tester.tap(find.text('Logs'));
      await tester.pumpAndSettle();

      expect(find.text('No logs available.'), findsOneWidget);
    });

    testWidgets('displays log lines when logs are available', (tester) async {
      final logLines = [
        {'message': 'Log line 1', 'timestamp': '2024-01-01T12:00:00Z'},
        {'message': 'Log line 2', 'timestamp': '2024-01-01T12:00:01Z'},
      ];

      await pumpLogsSection(tester, state: ContainerLogsLoaded(logLines));
      await tester.pumpAndSettle();

      // Expand the section
      await tester.tap(find.text('Logs'));
      await tester.pumpAndSettle();

      // Use textContaining because each Text.rich includes both timestamp and message spans
      expect(
        find.textContaining('Log line 1', findRichText: true),
        findsOneWidget,
      );
      expect(
        find.textContaining('Log line 2', findRichText: true),
        findsOneWidget,
      );
    });

    testWidgets('displays in a card', (tester) async {
      await pumpLogsSection(tester, state: const ContainerLogsInitial());
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('shows expand/collapse icon', (tester) async {
      await pumpLogsSection(tester, state: const ContainerLogsInitial());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);

      // Tap to expand
      await tester.tap(find.text('Logs'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.keyboard_arrow_up), findsOneWidget);
    });
  });
}
