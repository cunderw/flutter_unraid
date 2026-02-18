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
    registerFallbackValue(
      QueryOptions(document: gql('query {}')),
    );
    registerFallbackValue(
      MutationOptions(document: gql('mutation {}')),
    );
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

    test('throws exception on GraphQL error', () async {
      when(() => mockClient.query(any())).thenAnswer(
        (_) async => makeErrorQueryResult(
          OperationException(graphqlErrors: [GraphQLError(message: 'fail')]),
        ),
      );

      expect(() => repository.getNotifications(), throwsA(isA<OperationException>()));
    });
  });

  group('markAsRead', () {
    test('calls mutation with correct variables', () async {
      when(() => mockClient.mutate(any())).thenAnswer(
        (_) async => makeQueryResult(makeMutationResponseJson()),
      );

      await repository.markAsRead('notif-1');

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

      expect(() => repository.markAsRead('notif-1'), throwsA(isA<OperationException>()));
    });
  });

  group('markAllAsRead', () {
    test('calls mutation', () async {
      when(() => mockClient.mutate(any())).thenAnswer(
        (_) async => makeQueryResult(makeMutationResponseJson()),
      );

      await repository.markAllAsRead();

      verify(() => mockClient.mutate(any())).called(1);
    });

    test('throws exception on GraphQL error', () async {
      when(() => mockClient.mutate(any())).thenAnswer(
        (_) async => makeErrorQueryResult(
          OperationException(graphqlErrors: [GraphQLError(message: 'fail')]),
        ),
      );

      expect(() => repository.markAllAsRead(), throwsA(isA<OperationException>()));
    });
  });

  group('deleteNotification', () {
    test('calls mutation with correct variables', () async {
      when(() => mockClient.mutate(any())).thenAnswer(
        (_) async => makeQueryResult(makeMutationResponseJson()),
      );

      await repository.deleteNotification('notif-1');

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

      expect(() => repository.deleteNotification('notif-1'), throwsA(isA<OperationException>()));
    });
  });

  group('deleteAll', () {
    test('calls mutation', () async {
      when(() => mockClient.mutate(any())).thenAnswer(
        (_) async => makeQueryResult(makeMutationResponseJson()),
      );

      await repository.deleteAll();

      verify(() => mockClient.mutate(any())).called(1);
    });

    test('throws exception on GraphQL error', () async {
      when(() => mockClient.mutate(any())).thenAnswer(
        (_) async => makeErrorQueryResult(
          OperationException(graphqlErrors: [GraphQLError(message: 'fail')]),
        ),
      );

      expect(() => repository.deleteAll(), throwsA(isA<OperationException>()));
    });
  });
}
