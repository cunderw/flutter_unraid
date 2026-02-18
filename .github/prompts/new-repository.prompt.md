# New Repository

Scaffold a new repository that wraps GraphQL operations and returns parsed models.

## Inputs

- **Repository name** (e.g., `NotificationRepository`)
- **Model type** it returns (e.g., `Notification`)
- **Query names** from `lib/graphql/queries.dart` (e.g., `Queries.notifications`)
- **Mutation names** from `lib/graphql/mutations.dart` — optional
- **GraphQL response JSON path** (e.g., `data['notifications']['list']`)

## Output Files

1. `lib/data/repositories/<name>_repository.dart`
2. Update `test/helpers/mocks.dart` — add `MockRepository` if not present
3. Update `lib/di/injection.dart` — register as lazy singleton

## Repository Pattern

Follow `lib/data/repositories/docker_repository.dart` exactly:

```dart
import 'package:graphql/client.dart';

import 'package:flutter_unraid/data/models/<model>.dart';
import 'package:flutter_unraid/graphql/client.dart';
import 'package:flutter_unraid/graphql/queries.dart';
import 'package:flutter_unraid/graphql/mutations.dart'; // only if mutations used
import 'package:flutter_unraid/utils/log.dart';

class <Name>Repository {
  static const _tag = '<Name>Repository';
  final GraphQLClientManager _clientManager;

  <Name>Repository(this._clientManager);

  Future<List<Model>> getItems() async {
    Log.d('Fetching items', tag: _tag);
    final result = await _clientManager.client.query(
      QueryOptions(
        document: gql(Queries.itemQuery),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    if (result.hasException) throw result.exception!;
    final items = result.data!['path']['to']['list'] as List<dynamic>;
    Log.d('Fetched ${items.length} items', tag: _tag);
    return items
        .map((e) => Model.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Mutations: Log.i for info level, throw on exception
  Future<void> doAction(String id) async {
    Log.i('Performing action on $id', tag: _tag);
    final result = await _clientManager.client.mutate(
      MutationOptions(
        document: gql(Mutations.action),
        variables: {'id': id},
      ),
    );
    if (result.hasException) throw result.exception!;
    Log.i('Action on $id succeeded', tag: _tag);
  }
}
```

## Rules

- Constructor takes `GraphQLClientManager` — no other dependencies
- `static const _tag` for all log calls
- Queries use `FetchPolicy.networkOnly`
- Always check `result.hasException` and `throw result.exception!`
- Parse response JSON into models via `fromJson` factories
- `Log.d()` for queries (debug), `Log.i()` for mutations (info)
- DRY helper methods for repetitive mutations (see `_mutateContainer` in DockerRepository)

## Registration

Add to `lib/di/injection.dart`:

```dart
getIt.registerLazySingleton<<Name>Repository>(
  () => <Name>Repository(getIt<GraphQLClientManager>()),
);
```

## Mock

Add to `test/helpers/mocks.dart`:

```dart
class Mock<Name>Repository extends Mock implements <Name>Repository {}
```
