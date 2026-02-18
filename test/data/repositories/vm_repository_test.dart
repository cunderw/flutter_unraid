import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_unraid/data/repositories/vm_repository.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockGraphQLClientManager mockClientManager;
  late MockGraphQLClient mockClient;
  late VmRepository repo;

  setUpAll(() {
    registerFallbackValue(QueryOptions(document: gql('query {}')));
    registerFallbackValue(MutationOptions(document: gql('mutation {}')));
  });

  setUp(() {
    mockClientManager = MockGraphQLClientManager();
    mockClient = MockGraphQLClient();
    when(() => mockClientManager.client).thenReturn(mockClient);
    repo = VmRepository(mockClientManager);
  });

  group('VmRepository', () {
    group('getVms', () {
      test('returns list of VMs on success', () async {
        when(() => mockClient.query(any())).thenAnswer(
          (_) async => makeQueryResult(makeVmsResponseJson(count: 3)),
        );

        final result = await repo.getVms();

        expect(result.length, 3);
        expect(result[0].id, 'vm-0');
        expect(result[1].id, 'vm-1');
        expect(result[2].id, 'vm-2');
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
          () => repo.getVms(),
          throwsA(isA<OperationException>()),
        );
      });
    });

    group('startVm', () {
      test('calls mutation with correct variables', () async {
        when(() => mockClient.mutate(any())).thenAnswer(
          (_) async => makeQueryResult(makeMutationResponseJson()),
        );

        await repo.startVm('vm-1');

        final captured = verify(() => mockClient.mutate(captureAny())).captured;
        final options = captured.first as MutationOptions;
        expect(options.variables['id'], 'vm-1');
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
          () => repo.startVm('vm-1'),
          throwsA(isA<OperationException>()),
        );
      });
    });

    group('stopVm', () {
      test('calls mutation with correct variables', () async {
        when(() => mockClient.mutate(any())).thenAnswer(
          (_) async => makeQueryResult(makeMutationResponseJson()),
        );

        await repo.stopVm('vm-1');

        final captured = verify(() => mockClient.mutate(captureAny())).captured;
        final options = captured.first as MutationOptions;
        expect(options.variables['id'], 'vm-1');
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
          () => repo.stopVm('vm-1'),
          throwsA(isA<OperationException>()),
        );
      });
    });

    group('forceStopVm', () {
      test('calls mutation with correct variables', () async {
        when(() => mockClient.mutate(any())).thenAnswer(
          (_) async => makeQueryResult(makeMutationResponseJson()),
        );

        await repo.forceStopVm('vm-1');

        final captured = verify(() => mockClient.mutate(captureAny())).captured;
        final options = captured.first as MutationOptions;
        expect(options.variables['id'], 'vm-1');
      });

      test('throws exception when mutation fails', () async {
        when(() => mockClient.mutate(any())).thenAnswer(
          (_) async => makeErrorQueryResult(
            OperationException(
              graphqlErrors: [GraphQLError(message: 'Force stop failed')],
            ),
          ),
        );

        expect(
          () => repo.forceStopVm('vm-1'),
          throwsA(isA<OperationException>()),
        );
      });
    });

    group('pauseVm', () {
      test('calls mutation with correct variables', () async {
        when(() => mockClient.mutate(any())).thenAnswer(
          (_) async => makeQueryResult(makeMutationResponseJson()),
        );

        await repo.pauseVm('vm-1');

        final captured = verify(() => mockClient.mutate(captureAny())).captured;
        final options = captured.first as MutationOptions;
        expect(options.variables['id'], 'vm-1');
      });

      test('throws exception when mutation fails', () async {
        when(() => mockClient.mutate(any())).thenAnswer(
          (_) async => makeErrorQueryResult(
            OperationException(
              graphqlErrors: [GraphQLError(message: 'Pause failed')],
            ),
          ),
        );

        expect(
          () => repo.pauseVm('vm-1'),
          throwsA(isA<OperationException>()),
        );
      });
    });

    group('resumeVm', () {
      test('calls mutation with correct variables', () async {
        when(() => mockClient.mutate(any())).thenAnswer(
          (_) async => makeQueryResult(makeMutationResponseJson()),
        );

        await repo.resumeVm('vm-1');

        final captured = verify(() => mockClient.mutate(captureAny())).captured;
        final options = captured.first as MutationOptions;
        expect(options.variables['id'], 'vm-1');
      });

      test('throws exception when mutation fails', () async {
        when(() => mockClient.mutate(any())).thenAnswer(
          (_) async => makeErrorQueryResult(
            OperationException(
              graphqlErrors: [GraphQLError(message: 'Resume failed')],
            ),
          ),
        );

        expect(
          () => repo.resumeVm('vm-1'),
          throwsA(isA<OperationException>()),
        );
      });
    });

    group('rebootVm', () {
      test('calls mutation with correct variables', () async {
        when(() => mockClient.mutate(any())).thenAnswer(
          (_) async => makeQueryResult(makeMutationResponseJson()),
        );

        await repo.rebootVm('vm-1');

        final captured = verify(() => mockClient.mutate(captureAny())).captured;
        final options = captured.first as MutationOptions;
        expect(options.variables['id'], 'vm-1');
      });

      test('throws exception when mutation fails', () async {
        when(() => mockClient.mutate(any())).thenAnswer(
          (_) async => makeErrorQueryResult(
            OperationException(
              graphqlErrors: [GraphQLError(message: 'Reboot failed')],
            ),
          ),
        );

        expect(
          () => repo.rebootVm('vm-1'),
          throwsA(isA<OperationException>()),
        );
      });
    });
  });
}
