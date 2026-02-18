# GraphQL Query Builder

Generate complete GraphQL integration code: query/mutation string, model, repository method, and test fixtures.

## Usage

`/project:graphql-query-builder <description of data needed>`

## What to generate

### 1. GraphQL string

Add to `lib/graphql/queries.dart` (for queries) or `lib/graphql/mutations.dart` (for mutations):

```dart
static const String featureName = r'''
  query FeatureName {
    feature {
      items {
        id
        name
        status
      }
    }
  }
''';
```

Rules:
- Raw string literals (`r'''...'''`)
- `static const String` in `Queries` or `Mutations` class
- Only request fields the model will use

### 2. Model (`lib/data/models/<name>.dart`)

- `const` constructor, `Equatable`, `fromJson` — **no `toJson`**
- Enhanced enums with `fromString` for status/type fields
- Null-safe casts (`as String?`) for nullable API fields

### 3. Repository method

Add to existing or new repository in `lib/data/repositories/`:

```dart
Future<List<Feature>> getFeatures() async {
  Log.d(_tag, 'Fetching features');
  final result = await _clientManager.client.query(
    QueryOptions(
      document: gql(Queries.featureName),
      fetchPolicy: FetchPolicy.networkOnly,
    ),
  );
  if (result.hasException) throw result.exception!;
  final items = result.data!['feature']['items'] as List<dynamic>;
  return items.map((e) => Feature.fromJson(e as Map<String, dynamic>)).toList();
}
```

### 4. JSON fixture (`test/helpers/test_data.dart`)

```dart
Map<String, dynamic> makeFeatureResponseJson({
  List<Map<String, dynamic>>? items,
}) => {
  'feature': {
    'items': items ?? [{'id': 'feature-1', 'name': 'Test Feature', 'status': 'ACTIVE'}],
  },
};
```

### 5. Factory helper (`test/helpers/factories.dart`)

```dart
Feature makeFeature({
  String id = 'feature-1',
  String name = 'Test Feature',
  FeatureStatus status = FeatureStatus.active,
}) => Feature(id: id, name: name, status: status);
```

## Before generating

1. Read existing queries/mutations in `lib/graphql/` to match naming style
2. Read existing models in `lib/data/models/` to match patterns
3. Read existing repositories in `lib/data/repositories/` to match structure
4. Read existing test helpers to understand conventions

## After generating

Run `flutter analyze` and `flutter test` — both must pass.

$ARGUMENTS
