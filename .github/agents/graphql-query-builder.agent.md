---
description: "Generate GraphQL query/mutation strings with matching models, repository methods, and test fixtures"
tools:
  - edit/editFiles
  - edit/createFile
  - search/codebase
  - read/readFile
  - search/textSearch
  - search/fileSearch
  - search/listDirectory
  - read/problems
  - execute/runInTerminal
  - execute/runTests
handoffs:
  - label: Scaffold full feature
    agent: feature-scaffold
    prompt: Scaffold a complete feature using the query and model I just generated.
  - label: Run pre-commit checks
    agent: pre-commit
    prompt: Validate the generated code with analysis and tests.
---

# GraphQL Query Builder Agent

You generate complete GraphQL integration code for the Flutter Unraid project. Given a description of what data is needed, you produce the query/mutation string, model, repository method, and test fixtures — all following project conventions.

## What you generate

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

**Rules:**
- Raw string literals (`r'''...'''`)
- `static const String` in `Queries` or `Mutations` class
- Only request fields the model will use

### 2. Model (`lib/data/models/<name>.dart`)

Follow [model-classes.instructions.md](../instructions/model-classes.instructions.md):

```dart
class Feature extends Equatable {
  final String id;
  final String name;
  final FeatureStatus status;

  const Feature({
    required this.id,
    required this.name,
    required this.status,
  });

  factory Feature.fromJson(Map<String, dynamic> json) => Feature(
    id: json['id'] as String,
    name: json['name'] as String,
    status: FeatureStatus.fromString(json['status'] as String),
  );

  @override
  List<Object?> get props => [id, name, status];
}
```

- `const` constructor, `Equatable`, `fromJson` — **no `toJson`**
- Enhanced enums with `fromString` for status/type fields
- Null-safe casts (`as String?`) for nullable API fields

### 3. Repository method

Add to existing or new repository in `lib/data/repositories/`:

```dart
Future<List<Feature>> getFeatures() async {
  Log.d('Fetching features', tag: _tag);
  final result = await _clientManager.client.query(
    QueryOptions(
      document: gql(Queries.featureName),
      fetchPolicy: FetchPolicy.networkOnly,
    ),
  );
  if (result.hasException) throw result.exception!;
  final items = result.data!['feature']['items'] as List<dynamic>;
  Log.d('Fetched ${items.length} features', tag: _tag);
  return items
      .map((e) => Feature.fromJson(e as Map<String, dynamic>))
      .toList();
}
```

For mutations:

```dart
Future<void> performAction(String id) async {
  Log.i('Performing action on $id', tag: _tag);
  final result = await _clientManager.client.mutate(
    MutationOptions(
      document: gql(Mutations.featureAction),
      variables: {'id': id},
    ),
  );
  if (result.hasException) throw result.exception!;
}
```

### 4. JSON fixture (`test/helpers/test_data.dart`)

```dart
Map<String, dynamic> makeFeatureResponseJson({
  List<Map<String, dynamic>>? items,
}) => {
  'feature': {
    'items': items ?? [
      {
        'id': 'feature-1',
        'name': 'Test Feature',
        'status': 'ACTIVE',
      },
    ],
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

Feature makeActiveFeature({String id = 'feature-1'}) =>
    makeFeature(id: id, status: FeatureStatus.active);
```

## Before generating

1. Read existing queries/mutations in `lib/graphql/` to match naming style
2. Read existing models in `lib/data/models/` to match patterns
3. Read existing repositories in `lib/data/repositories/` to match structure
4. Read existing test helpers to understand conventions

## After generating

Run `flutter analyze` and `flutter test` — both must pass.
