import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_unraid/data/repositories/share_repository.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockGraphQLClientManager mockClientManager;
  late MockGraphQLClient mockClient;
  late ShareRepository repo;

  setUpAll(() {
    registerFallbackValue(QueryOptions(document: gql('query {}')));
  });

  setUp(() {
    mockClientManager = MockGraphQLClientManager();
    mockClient = MockGraphQLClient();
    when(() => mockClientManager.client).thenReturn(mockClient);
    repo = ShareRepository(mockClientManager);
  });

  group('ShareRepository', () {
    group('getShares', () {
      test('returns list of shares on success', () async {
        when(() => mockClient.query(any())).thenAnswer(
          (_) async => makeQueryResult(makeSharesResponseJson(count: 3)),
        );

        final result = await repo.getShares();

        expect(result.length, 3);
        expect(result[0].id, 'share-0');
        expect(result[1].id, 'share-1');
        expect(result[2].id, 'share-2');
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
          () => repo.getShares(),
          throwsA(isA<OperationException>()),
        );
      });
    });
  });
}
