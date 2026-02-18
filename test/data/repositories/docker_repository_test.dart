import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_unraid/data/repositories/docker_repository.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockGraphQLClientManager mockClientManager;
  late MockGraphQLClient mockClient;
  late DockerRepository repo;

  setUpAll(() {
    registerFallbackValue(QueryOptions(document: gql('query {}')));
    registerFallbackValue(MutationOptions(document: gql('mutation {}')));
  });

  setUp(() {
    mockClientManager = MockGraphQLClientManager();
    mockClient = MockGraphQLClient();
    when(() => mockClientManager.client).thenReturn(mockClient);
    repo = DockerRepository(mockClientManager);
  });

  group('DockerRepository', () {
    group('getContainers', () {
      test('returns list of containers on success', () async {
        when(() => mockClient.query(any())).thenAnswer(
          (_) async => makeQueryResult(makeContainersResponseJson(count: 3)),
        );

        final result = await repo.getContainers();

        expect(result.length, 3);
        expect(result[0].id, 'container-0');
        expect(result[1].id, 'container-1');
        verify(() => mockClient.query(any())).called(1);
      });

      test('throws exception when query fails', () async {
        when(() => mockClient.query(any())).thenAnswer(
          (_) async => makeErrorQueryResult(
            OperationException(
              graphqlErrors: [GraphQLError(message: 'Network error')],
            ),
          ),
        );

        expect(
          () => repo.getContainers(),
          throwsA(isA<OperationException>()),
        );
      });
    });

    group('startContainer', () {
      test('calls mutation with correct variables', () async {
        when(() => mockClient.mutate(any())).thenAnswer(
          (_) async => makeQueryResult(makeMutationResponseJson()),
        );

        await repo.startContainer('container-1');

        final captured = verify(() => mockClient.mutate(captureAny())).captured;
        final options = captured.first as MutationOptions;
        expect(options.variables['id'], 'container-1');
      });

      test('throws exception when mutation fails', () async {
        when(() => mockClient.mutate(any())).thenAnswer(
          (_) async => makeErrorQueryResult(
            OperationException(
              graphqlErrors: [GraphQLError(message: 'Start failed')],
            ),
          ),
        );

        expect(
          () => repo.startContainer('container-1'),
          throwsA(isA<OperationException>()),
        );
      });
    });

    group('stopContainer', () {
      test('calls mutation with correct variables', () async {
        when(() => mockClient.mutate(any())).thenAnswer(
          (_) async => makeQueryResult(makeMutationResponseJson()),
        );

        await repo.stopContainer('container-1');

        final captured = verify(() => mockClient.mutate(captureAny())).captured;
        final options = captured.first as MutationOptions;
        expect(options.variables['id'], 'container-1');
      });

      test('throws exception when mutation fails', () async {
        when(() => mockClient.mutate(any())).thenAnswer(
          (_) async => makeErrorQueryResult(
            OperationException(
              graphqlErrors: [GraphQLError(message: 'Stop failed')],
            ),
          ),
        );

        expect(
          () => repo.stopContainer('container-1'),
          throwsA(isA<OperationException>()),
        );
      });
    });

    group('restartContainer', () {
      test('calls mutation with correct variables', () async {
        when(() => mockClient.mutate(any())).thenAnswer(
          (_) async => makeQueryResult(makeMutationResponseJson()),
        );

        await repo.restartContainer('container-1');

        final captured = verify(() => mockClient.mutate(captureAny())).captured;
        final options = captured.first as MutationOptions;
        expect(options.variables['id'], 'container-1');
      });

      test('throws exception when mutation fails', () async {
        when(() => mockClient.mutate(any())).thenAnswer(
          (_) async => makeErrorQueryResult(
            OperationException(
              graphqlErrors: [GraphQLError(message: 'Restart failed')],
            ),
          ),
        );

        expect(
          () => repo.restartContainer('container-1'),
          throwsA(isA<OperationException>()),
        );
      });
    });

    group('removeContainer', () {
      test('calls mutation with correct variables', () async {
        when(() => mockClient.mutate(any())).thenAnswer(
          (_) async => makeQueryResult(makeMutationResponseJson()),
        );

        await repo.removeContainer('container-1', withImage: true);

        final captured = verify(() => mockClient.mutate(captureAny())).captured;
        final options = captured.first as MutationOptions;
        expect(options.variables['id'], 'container-1');
        expect(options.variables['withImage'], true);
      });

      test('defaults withImage to false', () async {
        when(() => mockClient.mutate(any())).thenAnswer(
          (_) async => makeQueryResult(makeMutationResponseJson()),
        );

        await repo.removeContainer('container-1');

        final captured = verify(() => mockClient.mutate(captureAny())).captured;
        final options = captured.first as MutationOptions;
        expect(options.variables['withImage'], false);
      });

      test('throws exception when mutation fails', () async {
        when(() => mockClient.mutate(any())).thenAnswer(
          (_) async => makeErrorQueryResult(
            OperationException(
              graphqlErrors: [GraphQLError(message: 'Remove failed')],
            ),
          ),
        );

        expect(
          () => repo.removeContainer('container-1'),
          throwsA(isA<OperationException>()),
        );
      });
    });

    group('getContainerLogs', () {
      test('returns list of log lines on success', () async {
        when(() => mockClient.query(any())).thenAnswer(
          (_) async => makeQueryResult(makeContainerLogsResponseJson(lineCount: 5)),
        );

        final result = await repo.getContainerLogs('container-1');

        expect(result.length, 5);
        expect(result[0]['message'], 'Log line 0');
        verify(() => mockClient.query(any())).called(1);
      });

      test('passes tail parameter to query', () async {
        when(() => mockClient.query(any())).thenAnswer(
          (_) async => makeQueryResult(makeContainerLogsResponseJson()),
        );

        await repo.getContainerLogs('container-1', tail: 50);

        final captured = verify(() => mockClient.query(captureAny())).captured;
        final options = captured.first as QueryOptions;
        expect(options.variables['id'], 'container-1');
        expect(options.variables['tail'], 50);
      });

      test('defaults tail to 100', () async {
        when(() => mockClient.query(any())).thenAnswer(
          (_) async => makeQueryResult(makeContainerLogsResponseJson()),
        );

        await repo.getContainerLogs('container-1');

        final captured = verify(() => mockClient.query(captureAny())).captured;
        final options = captured.first as QueryOptions;
        expect(options.variables['tail'], 100);
      });

      test('returns empty list when logs is null', () async {
        when(() => mockClient.query(any())).thenAnswer(
          (_) async => makeQueryResult({'docker': {'containerLogs': null}}),
        );

        final result = await repo.getContainerLogs('container-1');

        expect(result, isEmpty);
      });

      test('throws exception when query fails', () async {
        when(() => mockClient.query(any())).thenAnswer(
          (_) async => makeErrorQueryResult(
            OperationException(
              graphqlErrors: [GraphQLError(message: 'Logs fetch failed')],
            ),
          ),
        );

        expect(
          () => repo.getContainerLogs('container-1'),
          throwsA(isA<OperationException>()),
        );
      });
    });
  });
}
