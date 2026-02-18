import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_unraid/data/repositories/system_repository.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockGraphQLClientManager mockClientManager;
  late MockGraphQLClient mockClient;
  late SystemRepository repo;

  setUpAll(() {
    registerFallbackValue(QueryOptions(document: gql('query {}')));
    registerFallbackValue(MutationOptions(document: gql('mutation {}')));
  });

  setUp(() {
    mockClientManager = MockGraphQLClientManager();
    mockClient = MockGraphQLClient();
    when(() => mockClientManager.client).thenReturn(mockClient);
    repo = SystemRepository(mockClientManager);
  });

  group('SystemRepository', () {
    group('getSystemInfo', () {
      test('returns system info and memory on success', () async {
        when(() => mockClient.query(any())).thenAnswer(
          (_) async => makeQueryResult(makeSystemInfoResponseJson()),
        );

        final result = await repo.getSystemInfo();

        expect(result.systemInfo.os, isNotNull);
        expect(result.systemInfo.os!.platform, 'linux');
        expect(result.systemInfo.cpu, isNotNull);
        expect(result.systemInfo.cpu!.manufacturer, 'Intel');
        expect(result.memory, isNotNull);
        expect(result.memory!.percentTotal, 50.0);
        verify(() => mockClient.query(any())).called(1);
      });

      test('handles missing memory data', () async {
        when(() => mockClient.query(any())).thenAnswer(
          (_) async => makeQueryResult({
            'info': {
              'os': {'platform': 'linux'},
              'cpu': {'cores': 8},
            },
            'metrics': null,
          }),
        );

        final result = await repo.getSystemInfo();

        expect(result.systemInfo, isNotNull);
        expect(result.memory, isNull);
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
          () => repo.getSystemInfo(),
          throwsA(isA<OperationException>()),
        );
      });
    });

    group('getArrayData', () {
      test('returns array data on success', () async {
        when(() => mockClient.query(any())).thenAnswer(
          (_) async => makeQueryResult(makeArrayDataResponseJson()),
        );

        final result = await repo.getArrayData();

        expect(result.state, 'STARTED');
        expect(result.capacity, isNotNull);
        expect(result.disks.length, 1);
        expect(result.parities.length, 1);
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
          () => repo.getArrayData(),
          throwsA(isA<OperationException>()),
        );
      });
    });

    group('setArrayState', () {
      test('calls mutation with correct variables', () async {
        when(() => mockClient.mutate(any())).thenAnswer(
          (_) async => makeQueryResult(makeMutationResponseJson()),
        );

        await repo.setArrayState('STARTED');

        final captured = verify(() => mockClient.mutate(captureAny())).captured;
        final options = captured.first as MutationOptions;
        expect(options.variables['desiredState'], 'STARTED');
      });

      test('throws exception when mutation fails', () async {
        when(() => mockClient.mutate(any())).thenAnswer(
          (_) async => makeErrorQueryResult(
            OperationException(
              graphqlErrors: [GraphQLError(message: 'Set state failed')],
            ),
          ),
        );

        expect(
          () => repo.setArrayState('STARTED'),
          throwsA(isA<OperationException>()),
        );
      });
    });
  });
}
