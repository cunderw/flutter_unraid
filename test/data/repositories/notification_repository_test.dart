import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_unraid/data/models/notification.dart';
import 'package:flutter_unraid/data/repositories/notification_repository.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockGraphQLClientManager mockClientManager;
  late MockGraphQLClient mockClient;
  late NotificationRepository repository;

  setUpAll(() {
    registerFallbackValue(QueryOptions(document: gql('query {}')));
    registerFallbackValue(MutationOptions(document: gql('mutation {}')));
  });

  setUp(() {
    mockClientManager = MockGraphQLClientManager();
    mockClient = MockGraphQLClient();
    repository = NotificationRepository(mockClientManager);

    when(() => mockClientManager.client).thenReturn(mockClient);
  });

  group('getNotifications', () {
    test('returns list of notifications on success', () async {
      when(() => mockClient.query(any())).thenAnswer(
        (_) async => makeQueryResult(makeNotificationsResponseJson(count: 3)),
      );

      final result = await repository.getNotifications();

      expect(result, isA<List<Notification>>());
      expect(result.length, 3);
      verify(
        () => mockClient.query(
          any(
            that: predicate<QueryOptions>(
              (opts) => opts.document.definitions.isNotEmpty,
            ),
          ),
        ),
      ).called(1);
    });

    test('passes filter variables to query', () async {
      when(() => mockClient.query(any())).thenAnswer(
        (_) async => makeQueryResult(makeNotificationsResponseJson()),
      );

      await repository.getNotifications(type: 'ARCHIVE', offset: 10, limit: 50);

      verify(
        () => mockClient.query(
          any(
            that: predicate<QueryOptions>(
              (opts) =>
                  opts.variables['type'] == 'ARCHIVE' &&
                  opts.variables['offset'] == 10 &&
                  opts.variables['limit'] == 50,
            ),
          ),
        ),
      ).called(1);
    });

    test('throws exception on GraphQL error', () async {
      when(() => mockClient.query(any())).thenAnswer(
        (_) async => makeErrorQueryResult(
          OperationException(graphqlErrors: [GraphQLError(message: 'fail')]),
        ),
      );

      expect(
        () => repository.getNotifications(),
        throwsA(isA<OperationException>()),
      );
    });
  });

  group('archiveNotification', () {
    test('calls mutation with correct variables', () async {
      when(
        () => mockClient.mutate(any()),
      ).thenAnswer((_) async => makeQueryResult(makeMutationResponseJson()));

      await repository.archiveNotification('notif-1');

      verify(
        () => mockClient.mutate(
          any(
            that: predicate<MutationOptions>(
              (opts) => opts.variables['id'] == 'notif-1',
            ),
          ),
        ),
      ).called(1);
    });

    test('throws exception on GraphQL error', () async {
      when(() => mockClient.mutate(any())).thenAnswer(
        (_) async => makeErrorQueryResult(
          OperationException(graphqlErrors: [GraphQLError(message: 'fail')]),
        ),
      );

      expect(
        () => repository.archiveNotification('notif-1'),
        throwsA(isA<OperationException>()),
      );
    });
  });

  group('archiveAllNotifications', () {
    test('calls mutation with list of ids', () async {
      when(
        () => mockClient.mutate(any()),
      ).thenAnswer((_) async => makeQueryResult(makeMutationResponseJson()));

      await repository.archiveAllNotifications(['notif-1', 'notif-2']);

      verify(
        () => mockClient.mutate(
          any(
            that: predicate<MutationOptions>((opts) {
              final ids = opts.variables['ids'] as List;
              return ids.length == 2 &&
                  ids[0] == 'notif-1' &&
                  ids[1] == 'notif-2';
            }),
          ),
        ),
      ).called(1);
    });

    test('throws exception on GraphQL error', () async {
      when(() => mockClient.mutate(any())).thenAnswer(
        (_) async => makeErrorQueryResult(
          OperationException(graphqlErrors: [GraphQLError(message: 'fail')]),
        ),
      );

      expect(
        () => repository.archiveAllNotifications(['notif-1']),
        throwsA(isA<OperationException>()),
      );
    });
  });

  group('unreadNotification', () {
    test('calls mutation with correct variables', () async {
      when(
        () => mockClient.mutate(any()),
      ).thenAnswer((_) async => makeQueryResult(makeMutationResponseJson()));

      await repository.unreadNotification('notif-1');

      verify(
        () => mockClient.mutate(
          any(
            that: predicate<MutationOptions>(
              (opts) => opts.variables['id'] == 'notif-1',
            ),
          ),
        ),
      ).called(1);
    });

    test('throws exception on GraphQL error', () async {
      when(() => mockClient.mutate(any())).thenAnswer(
        (_) async => makeErrorQueryResult(
          OperationException(graphqlErrors: [GraphQLError(message: 'fail')]),
        ),
      );

      expect(
        () => repository.unreadNotification('notif-1'),
        throwsA(isA<OperationException>()),
      );
    });
  });

  group('deleteNotification', () {
    test('calls mutation with correct variables', () async {
      when(
        () => mockClient.mutate(any()),
      ).thenAnswer((_) async => makeQueryResult(makeMutationResponseJson()));

      await repository.deleteNotification('notif-1');

      verify(
        () => mockClient.mutate(
          any(
            that: predicate<MutationOptions>(
              (opts) =>
                  opts.variables['id'] == 'notif-1' &&
                  opts.variables['type'] == 'UNREAD',
            ),
          ),
        ),
      ).called(1);
    });

    test('throws exception on GraphQL error', () async {
      when(() => mockClient.mutate(any())).thenAnswer(
        (_) async => makeErrorQueryResult(
          OperationException(graphqlErrors: [GraphQLError(message: 'fail')]),
        ),
      );

      expect(
        () => repository.deleteNotification('notif-1'),
        throwsA(isA<OperationException>()),
      );
    });
  });

  group('deleteArchivedNotifications', () {
    test('calls mutation', () async {
      when(
        () => mockClient.mutate(any()),
      ).thenAnswer((_) async => makeQueryResult(makeMutationResponseJson()));

      await repository.deleteArchivedNotifications();

      verify(() => mockClient.mutate(any())).called(1);
    });

    test('throws exception on GraphQL error', () async {
      when(() => mockClient.mutate(any())).thenAnswer(
        (_) async => makeErrorQueryResult(
          OperationException(graphqlErrors: [GraphQLError(message: 'fail')]),
        ),
      );

      expect(
        () => repository.deleteArchivedNotifications(),
        throwsA(isA<OperationException>()),
      );
    });
  });
}
