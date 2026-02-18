import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_unraid/blocs/notifications/notification_cubit.dart';
import 'package:flutter_unraid/blocs/notifications/notification_state.dart';

import '../../helpers/factories.dart';
import '../../helpers/mocks.dart';

void main() {
  late MockNotificationRepository mockRepo;

  setUp(() {
    mockRepo = MockNotificationRepository();
  });

  NotificationCubit buildCubit() => NotificationCubit(mockRepo);

  group('NotificationCubit', () {
    test('initial state is NotificationInitial', () {
      expect(buildCubit().state, const NotificationInitial());
    });

    group('load', () {
      blocTest<NotificationCubit, NotificationState>(
        'emits [NotificationLoading, NotificationLoaded] on success',
        build: () {
          when(() => mockRepo.getNotifications()).thenAnswer(
            (_) async => [
              makeUnreadNotification(),
              makeReadNotification(),
              makeAlertNotification(),
            ],
          );
          return buildCubit();
        },
        act: (cubit) => cubit.load(),
        expect: () => [
          const NotificationLoading(),
          isA<NotificationLoaded>().having(
            (s) => s.notifications.length,
            'notification count',
            3,
          ),
        ],
      );

      blocTest<NotificationCubit, NotificationState>(
        'emits [NotificationLoading, NotificationError] on failure',
        build: () {
          when(() => mockRepo.getNotifications()).thenThrow(Exception('fail'));
          return buildCubit();
        },
        act: (cubit) => cubit.load(),
        expect: () => [const NotificationLoading(), isA<NotificationError>()],
      );
    });

    group('markAsRead', () {
      blocTest<NotificationCubit, NotificationState>(
        'calls repository and reloads on success',
        build: () {
          when(() => mockRepo.markAsRead(any())).thenAnswer((_) async {});
          when(() => mockRepo.getNotifications()).thenAnswer(
            (_) async => [makeReadNotification(id: 'notif-1')],
          );
          return buildCubit();
        },
        act: (cubit) => cubit.markAsRead('notif-1'),
        expect: () => [const NotificationLoading(), isA<NotificationLoaded>()],
        verify: (_) {
          verify(() => mockRepo.markAsRead('notif-1')).called(1);
        },
      );

      blocTest<NotificationCubit, NotificationState>(
        'emits NotificationActionError when action fails and state is NotificationLoaded',
        seed: () => NotificationLoaded([makeUnreadNotification()]),
        build: () {
          when(() => mockRepo.markAsRead(any())).thenThrow(Exception('fail'));
          return buildCubit();
        },
        act: (cubit) => cubit.markAsRead('notif-1'),
        expect: () => [isA<NotificationActionError>()],
      );
    });

    group('markAllAsRead', () {
      blocTest<NotificationCubit, NotificationState>(
        'calls repository and reloads on success',
        build: () {
          when(() => mockRepo.markAllAsRead()).thenAnswer((_) async {});
          when(() => mockRepo.getNotifications()).thenAnswer(
            (_) async => [
              makeReadNotification(id: 'notif-1'),
              makeReadNotification(id: 'notif-2'),
            ],
          );
          return buildCubit();
        },
        act: (cubit) => cubit.markAllAsRead(),
        expect: () => [const NotificationLoading(), isA<NotificationLoaded>()],
        verify: (_) {
          verify(() => mockRepo.markAllAsRead()).called(1);
        },
      );

      blocTest<NotificationCubit, NotificationState>(
        'emits NotificationActionError when action fails and state is NotificationLoaded',
        seed: () => NotificationLoaded([makeUnreadNotification()]),
        build: () {
          when(() => mockRepo.markAllAsRead()).thenThrow(Exception('fail'));
          return buildCubit();
        },
        act: (cubit) => cubit.markAllAsRead(),
        expect: () => [isA<NotificationActionError>()],
      );
    });

    group('deleteNotification', () {
      blocTest<NotificationCubit, NotificationState>(
        'calls repository and reloads on success',
        build: () {
          when(() => mockRepo.deleteNotification(any())).thenAnswer((_) async {});
          when(() => mockRepo.getNotifications()).thenAnswer((_) async => []);
          return buildCubit();
        },
        act: (cubit) => cubit.deleteNotification('notif-1'),
        expect: () => [
          const NotificationLoading(),
          isA<NotificationLoaded>().having(
            (s) => s.notifications.length,
            'notification count',
            0,
          ),
        ],
        verify: (_) {
          verify(() => mockRepo.deleteNotification('notif-1')).called(1);
        },
      );

      blocTest<NotificationCubit, NotificationState>(
        'emits NotificationActionError when action fails and state is NotificationLoaded',
        seed: () => NotificationLoaded([makeUnreadNotification()]),
        build: () {
          when(() => mockRepo.deleteNotification(any())).thenThrow(Exception('fail'));
          return buildCubit();
        },
        act: (cubit) => cubit.deleteNotification('notif-1'),
        expect: () => [isA<NotificationActionError>()],
      );
    });

    group('deleteAll', () {
      blocTest<NotificationCubit, NotificationState>(
        'calls repository and reloads on success',
        build: () {
          when(() => mockRepo.deleteAll()).thenAnswer((_) async {});
          when(() => mockRepo.getNotifications()).thenAnswer((_) async => []);
          return buildCubit();
        },
        act: (cubit) => cubit.deleteAll(),
        expect: () => [
          const NotificationLoading(),
          isA<NotificationLoaded>().having(
            (s) => s.notifications.length,
            'notification count',
            0,
          ),
        ],
        verify: (_) {
          verify(() => mockRepo.deleteAll()).called(1);
        },
      );

      blocTest<NotificationCubit, NotificationState>(
        'emits NotificationError when action fails and state is not NotificationLoaded',
        build: () {
          when(() => mockRepo.deleteAll()).thenThrow(Exception('fail'));
          return buildCubit();
        },
        act: (cubit) => cubit.deleteAll(),
        expect: () => [isA<NotificationError>()],
      );
    });

    group('NotificationLoaded helpers', () {
      test('unreadCount, alertCount, and warningCount are correct', () {
        final state = NotificationLoaded([
          makeUnreadNotification(id: 'n1'),
          makeReadNotification(id: 'n2'),
          makeAlertNotification(id: 'n3'),
          makeWarningNotification(id: 'n4'),
        ]);
        expect(state.unreadCount, 3); // n1, n3, n4 are unread
        expect(state.alertCount, 1); // n3
        expect(state.warningCount, 1); // n4
      });
    });
  });
}
