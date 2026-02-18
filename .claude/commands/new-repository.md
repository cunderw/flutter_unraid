# New Repository

Scaffold a new repository that wraps GraphQL operations and returns parsed models.

## Usage

`/project:new-repository <repository name and details>`

Provide: repository name, model type it returns, query/mutation names, and GraphQL response JSON path.

## Output Files

1. `lib/data/repositories/<name>_repository.dart`
2. Update `test/helpers/mocks.dart` — add `MockRepository`
3. Update `lib/di/injection.dart` — register as lazy singleton

## Repository Pattern

Follow `lib/data/repositories/docker_repository.dart`:

```dart
import 'package:graphql/client.dart';

import 'package:flutter_unraid/data/models/<model>.dart';
import 'package:flutter_unraid/graphql/client.dart';
import 'package:flutter_unraid/graphql/queries.dart';
import 'package:flutter_unraid/graphql/mutations.dart';
import 'package:flutter_unraid/utils/log.dart';

class FeatureRepository {
  static const _tag = 'FeatureRepository';
  final GraphQLClientManager _clientManager;

  FeatureRepository(this._clientManager);

  Future<List<Model>> getItems() async {
    Log.d(_tag, 'Fetching items');
    final result = await _clientManager.client.query(
      QueryOptions(
        document: gql(Queries.itemQuery),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    if (result.hasException) throw result.exception!;
    final items = result.data!['path']['to']['list'] as List<dynamic>;
    return items.map((e) => Model.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> doAction(String id) async {
    Log.i(_tag, 'Performing action on $id');
    final result = await _clientManager.client.mutate(
      MutationOptions(
        document: gql(Mutations.action),
        variables: {'id': id},
      ),
    );
    if (result.hasException) throw result.exception!;
  }
}
```

## Rules

- Constructor takes `GraphQLClientManager` — no other dependencies, no `getIt` lookups
- `static const _tag` for all log calls
- Queries use `FetchPolicy.networkOnly`
- Always check `result.hasException` and `throw result.exception!`
- Parse response JSON into models via `fromJson` factories
- `Log.d()` for queries (debug), `Log.i()` for mutations (info)

## DI Registration

Add to `lib/di/injection.dart`:

```dart
getIt.registerLazySingleton<FeatureRepository>(
  () => FeatureRepository(getIt<GraphQLClientManager>()),
);
```

## Mock

Add to `test/helpers/mocks.dart`:

```dart
class MockFeatureRepository extends Mock implements FeatureRepository {}
```

$ARGUMENTS
