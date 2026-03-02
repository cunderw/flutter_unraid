import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_unraid/blocs/notifications/notification_cubit.dart';
import 'package:flutter_unraid/blocs/notifications/notification_state.dart';
import 'package:flutter_unraid/ui/screens/notifications/notifications_screen.dart';

import '../../../helpers/factories.dart';
import '../../../helpers/mocks.dart';
import '../../../helpers/pump_helpers.dart';

void main() {
  late MockNotificationCubit mockCubit;

  setUp(() {
    mockCubit = MockNotificationCubit();
    when(() => mockCubit.load()).thenAnswer((_) async {});
    when(() => mockCubit.refresh()).thenAnswer((_) async {});
    when(() => mockCubit.archiveAllNotifications()).thenAnswer((_) async {});
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    required NotificationState state,
  }) async {
    when(() => mockCubit.state).thenReturn(state);
    whenListen(
      mockCubit,
      Stream<NotificationState>.empty(),
      initialState: state,
    );
    await tester.pumpAppWithBlocs(
      const NotificationsScreen(),
      providers: [BlocProvider<NotificationCubit>.value(value: mockCubit)],
    );
  }

  group('NotificationsScreen', () {
    testWidgets('displays app bar with title', (tester) async {
      await pumpScreen(tester, state: const NotificationLoading());
      await tester.pump();

      expect(find.text('Notifications'), findsOneWidget);
    });

    testWidgets('shows loading indicator in Loading state', (tester) async {
      await pumpScreen(tester, state: const NotificationLoading());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading notifications...'), findsOneWidget);
    });

    testWidgets('shows error message in Error state', (tester) async {
      await pumpScreen(
        tester,
        state: const NotificationError('Failed to load'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Failed to load'), findsOneWidget);
    });

    testWidgets('shows empty state when no notifications', (tester) async {
      await pumpScreen(tester, state: const NotificationLoaded([]));
      await tester.pumpAndSettle();

      expect(find.text('No notifications.'), findsOneWidget);
    });

    testWidgets('shows notifications list in Loaded state', (tester) async {
      final notifications = [
        makeNotification(id: '1', subject: 'Alert 1'),
        makeNotification(id: '2', subject: 'Alert 2'),
      ];
      await pumpScreen(tester, state: NotificationLoaded(notifications));
      await tester.pumpAndSettle();

      expect(find.text('Alert 1'), findsOneWidget);
      expect(find.text('Alert 2'), findsOneWidget);
    });

    testWidgets('shows archive all button when notifications exist', (
      tester,
    ) async {
      final notifications = [makeNotification()];
      await pumpScreen(tester, state: NotificationLoaded(notifications));
      await tester.pumpAndSettle();

      expect(find.text('Archive all'), findsOneWidget);
    });

    testWidgets('hides archive all button when no notifications', (
      tester,
    ) async {
      await pumpScreen(tester, state: const NotificationLoaded([]));
      await tester.pumpAndSettle();

      expect(find.text('Archive all'), findsNothing);
    });

    testWidgets('shows notification count in section header', (tester) async {
      final notifications = [
        makeNotification(id: '1'),
        makeNotification(id: '2'),
      ];
      await pumpScreen(tester, state: NotificationLoaded(notifications));
      await tester.pumpAndSettle();

      expect(find.text('2 notifications'), findsOneWidget);
    });

    testWidgets('tapping archive all calls cubit', (tester) async {
      final notifications = [makeNotification()];
      await pumpScreen(tester, state: NotificationLoaded(notifications));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Archive all'));
      await tester.pumpAndSettle();

      verify(() => mockCubit.archiveAllNotifications()).called(1);
    });
  });
}
