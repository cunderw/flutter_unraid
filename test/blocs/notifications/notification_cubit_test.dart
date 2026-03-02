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
          when(
            () => mockRepo.getNotifications(
              type: any(named: 'type'),
              offset: any(named: 'offset'),
              limit: any(named: 'limit'),
            ),
          ).thenAnswer(
            (_) async => [
              makeUnreadNotification(),
              makeArchivedNotification(),
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
          when(
            () => mockRepo.getNotifications(
              type: any(named: 'type'),
              offset: any(named: 'offset'),
              limit: any(named: 'limit'),
            ),
          ).thenThrow(Exception('fail'));
          return buildCubit();
        },
        act: (cubit) => cubit.load(),
        expect: () => [const NotificationLoading(), isA<NotificationError>()],
      );
    });

    group('archiveNotification', () {
      blocTest<NotificationCubit, NotificationState>(
        'calls repository and reloads on success',
        build: () {
          when(
            () => mockRepo.archiveNotification(any()),
          ).thenAnswer((_) async {});
          when(
            () => mockRepo.getNotifications(
              type: any(named: 'type'),
              offset: any(named: 'offset'),
              limit: any(named: 'limit'),
            ),
          ).thenAnswer((_) async => [makeArchivedNotification(id: 'notif-1')]);
          return buildCubit();
        },
        act: (cubit) => cubit.archiveNotification('notif-1'),
        expect: () => [const NotificationLoading(), isA<NotificationLoaded>()],
        verify: (_) {
          verify(() => mockRepo.archiveNotification('notif-1')).called(1);
        },
      );

      blocTest<NotificationCubit, NotificationState>(
        'emits NotificationActionError when action fails and state is NotificationLoaded',
        seed: () => NotificationLoaded([makeUnreadNotification()]),
        build: () {
          when(
            () => mockRepo.archiveNotification(any()),
          ).thenThrow(Exception('fail'));
          return buildCubit();
        },
        act: (cubit) => cubit.archiveNotification('notif-1'),
        expect: () => [isA<NotificationActionError>()],
      );
    });

    group('archiveAllNotifications', () {
      blocTest<NotificationCubit, NotificationState>(
        'calls repository with ids from loaded state and reloads on success',
        seed: () => NotificationLoaded([
          makeUnreadNotification(id: 'notif-1'),
          makeUnreadNotification(id: 'notif-2'),
        ]),
        build: () {
          when(
            () => mockRepo.archiveAllNotifications(any()),
          ).thenAnswer((_) async {});
          when(
            () => mockRepo.getNotifications(
              type: any(named: 'type'),
              offset: any(named: 'offset'),
              limit: any(named: 'limit'),
            ),
          ).thenAnswer((_) async => []);
          return buildCubit();
        },
        act: (cubit) => cubit.archiveAllNotifications(),
        expect: () => [const NotificationLoading(), isA<NotificationLoaded>()],
        verify: (_) {
          verify(
            () => mockRepo.archiveAllNotifications(['notif-1', 'notif-2']),
          ).called(1);
        },
      );

      blocTest<NotificationCubit, NotificationState>(
        'emits NotificationActionError when action fails and state is NotificationLoaded',
        seed: () => NotificationLoaded([makeUnreadNotification()]),
        build: () {
          when(
            () => mockRepo.archiveAllNotifications(any()),
          ).thenThrow(Exception('fail'));
          return buildCubit();
        },
        act: (cubit) => cubit.archiveAllNotifications(),
        expect: () => [isA<NotificationActionError>()],
      );
    });

    group('unreadNotification', () {
      blocTest<NotificationCubit, NotificationState>(
        'calls repository and reloads on success',
        build: () {
          when(
            () => mockRepo.unreadNotification(any()),
          ).thenAnswer((_) async {});
          when(
            () => mockRepo.getNotifications(
              type: any(named: 'type'),
              offset: any(named: 'offset'),
              limit: any(named: 'limit'),
            ),
          ).thenAnswer((_) async => [makeUnreadNotification(id: 'notif-1')]);
          return buildCubit();
        },
        act: (cubit) => cubit.unreadNotification('notif-1'),
        expect: () => [const NotificationLoading(), isA<NotificationLoaded>()],
        verify: (_) {
          verify(() => mockRepo.unreadNotification('notif-1')).called(1);
        },
      );

      blocTest<NotificationCubit, NotificationState>(
        'emits NotificationActionError when action fails and state is NotificationLoaded',
        seed: () => NotificationLoaded([makeUnreadNotification()]),
        build: () {
          when(
            () => mockRepo.unreadNotification(any()),
          ).thenThrow(Exception('fail'));
          return buildCubit();
        },
        act: (cubit) => cubit.unreadNotification('notif-1'),
        expect: () => [isA<NotificationActionError>()],
      );
    });

    group('deleteNotification', () {
      blocTest<NotificationCubit, NotificationState>(
        'calls repository and reloads on success',
        build: () {
          when(
            () => mockRepo.deleteNotification(any()),
          ).thenAnswer((_) async {});
          when(
            () => mockRepo.getNotifications(
              type: any(named: 'type'),
              offset: any(named: 'offset'),
              limit: any(named: 'limit'),
            ),
          ).thenAnswer((_) async => []);
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
          when(
            () => mockRepo.deleteNotification(any()),
          ).thenThrow(Exception('fail'));
          return buildCubit();
        },
        act: (cubit) => cubit.deleteNotification('notif-1'),
        expect: () => [isA<NotificationActionError>()],
      );
    });

    group('deleteArchivedNotifications', () {
      blocTest<NotificationCubit, NotificationState>(
        'calls repository and reloads on success',
        build: () {
          when(
            () => mockRepo.deleteArchivedNotifications(),
          ).thenAnswer((_) async {});
          when(
            () => mockRepo.getNotifications(
              type: any(named: 'type'),
              offset: any(named: 'offset'),
              limit: any(named: 'limit'),
            ),
          ).thenAnswer((_) async => []);
          return buildCubit();
        },
        act: (cubit) => cubit.deleteArchivedNotifications(),
        expect: () => [
          const NotificationLoading(),
          isA<NotificationLoaded>().having(
            (s) => s.notifications.length,
            'notification count',
            0,
          ),
        ],
        verify: (_) {
          verify(() => mockRepo.deleteArchivedNotifications()).called(1);
        },
      );

      blocTest<NotificationCubit, NotificationState>(
        'emits NotificationError when action fails and state is not NotificationLoaded',
        build: () {
          when(
            () => mockRepo.deleteArchivedNotifications(),
          ).thenThrow(Exception('fail'));
          return buildCubit();
        },
        act: (cubit) => cubit.deleteArchivedNotifications(),
        expect: () => [isA<NotificationError>()],
      );
    });

    group('NotificationLoaded helpers', () {
      test('totalCount, alertCount, and warningCount are correct', () {
        final state = NotificationLoaded([
          makeUnreadNotification(id: 'n1'),
          makeArchivedNotification(id: 'n2'),
          makeAlertNotification(id: 'n3'),
          makeWarningNotification(id: 'n4'),
        ]);
        expect(state.totalCount, 4);
        expect(state.alertCount, 1); // n3
        expect(state.warningCount, 1); // n4
      });
    });
  });
}
