---
applyTo: "**/repositories/*.dart"
---

# Repository Instructions

## Structure

```dart
class FeatureRepository {
  static const _tag = 'FeatureRepository';
  final GraphQLClientManager _client;

  FeatureRepository(this._client);

  Future<List<Feature>> getItems() async {
    Log.d(_tag, 'Fetching items');
    final result = await _client.query(
      QueryOptions(
        document: gql(Queries.featureItems),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    if (result.hasException) throw result.exception!;
    final list = result.data!['feature']['items'] as List;
    return list.map((e) => Feature.fromJson(e as Map<String, dynamic>)).toList();
  }
}
```

## Rules

- Accept `GraphQLClientManager` via constructor (not `getIt` lookups).
- Always use `FetchPolicy.networkOnly` for queries.
- Parse JSON into models via `fromJson` factories.
- Throw `result.exception!` on GraphQL errors — cubits catch and wrap these.
- Use `_tag` for all `Log` calls.
- Logging: `Log.d` for query start, `Log.i` for mutation start.

## GraphQL strings

- Query strings go in `lib/graphql/queries.dart` as `static const String` in the `Queries` class.
- Mutation strings go in `lib/graphql/mutations.dart` as `static const String` in the `Mutations` class.
- Use raw string literals: `r'''...'''`.

## After creating a repository

- Register as lazy singleton in `lib/di/injection.dart`.
- Add a `MockFeatureRepository` in `test/helpers/mocks.dart`.
- Add a `make<Type>ResponseJson()` fixture in `test/helpers/test_data.dart` matching the GraphQL response shape.
