# Feature Scaffold

Scaffold a complete new feature across all architecture layers from a single description.

## Usage

`/project:feature-scaffold <feature description>`

Provide: feature name, model type, data fields, whether it has mutations, and scope (app-wide vs screen-scoped).

## Checklist — Create ALL of these

### 1. Model (`lib/data/models/<feature>.dart`)

- `const` constructor with named parameters, extend `Equatable`
- `factory fromJson(Map<String, dynamic> json)` — **no `toJson`** (read-only API)
- Null-safe JSON parsing with `as Type?` casts
- Enhanced enums with `fromString` factory where applicable
- Computed getters for derived state

```dart
class Feature extends Equatable {
  final String id;
  final String name;
  final FeatureStatus status;

  const Feature({required this.id, required this.name, required this.status});

  factory Feature.fromJson(Map<String, dynamic> json) => Feature(
    id: json['id'] as String,
    name: json['name'] as String,
    status: FeatureStatus.fromString(json['status'] as String),
  );

  bool get isActive => status == FeatureStatus.active;

  @override
  List<Object?> get props => [id, name, status];
}
```

### 2. GraphQL strings

- **Queries** → `lib/graphql/queries.dart` as `static const String` in `Queries` class
- **Mutations** → `lib/graphql/mutations.dart` as `static const String` in `Mutations` class
- Use raw string literals (`r'''...'''`)

### 3. Repository (`lib/data/repositories/<feature>_repository.dart`)

- Accept `GraphQLClientManager` via constructor
- `static const _tag = '<Feature>Repository';`
- `FetchPolicy.networkOnly` for queries
- Parse JSON via `fromJson`, throw `result.exception!` on errors
- `Log.d` for queries, `Log.i` for mutations

```dart
class FeatureRepository {
  static const _tag = 'FeatureRepository';
  final GraphQLClientManager _clientManager;

  FeatureRepository(this._clientManager);

  Future<List<Feature>> getItems() async {
    Log.d(_tag, 'Fetching items');
    final result = await _clientManager.client.query(
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

### 4. Cubit (`lib/blocs/<feature>/<feature>_cubit.dart`)

- `static const _tag = '<Feature>Cubit';`
- Constructor takes repository, `super(const <Feature>Initial())`
- `load()`: emit Loading → repo call → emit Loaded; catch → `AppException.from(e, st)` + `Log.e` + emit Error
- Mutations emit `ActionError` when loaded data exists (preserves UI)

```dart
class FeatureCubit extends Cubit<FeatureState> {
  static const _tag = 'FeatureCubit';
  final FeatureRepository _repository;

  FeatureCubit(this._repository) : super(const FeatureInitial());

  Future<void> load() async {
    emit(const FeatureLoading());
    try {
      final data = await _repository.getItems();
      emit(FeatureLoaded(data));
    } catch (e, st) {
      final exception = AppException.from(e, st);
      Log.e(_tag, 'Failed to load', error: exception);
      emit(FeatureError(exception.message));
    }
  }
}
```

### 5. State (`lib/blocs/<feature>/<feature>_state.dart`)

Sealed class hierarchy: `Initial`, `Loading`, `Loaded`, `Error`, optionally `ActionError`.

```dart
sealed class FeatureState extends Equatable {
  const FeatureState();
  @override
  List<Object?> get props => [];
}

final class FeatureInitial extends FeatureState { const FeatureInitial(); }
final class FeatureLoading extends FeatureState { const FeatureLoading(); }

final class FeatureLoaded extends FeatureState {
  final List<Feature> items;
  const FeatureLoaded(this.items);
  @override
  List<Object?> get props => [items];
}

final class FeatureError extends FeatureState {
  final String message;
  const FeatureError(this.message);
  @override
  List<Object?> get props => [message];
}

final class FeatureActionError extends FeatureState {
  final List<Feature> items;
  final String message;
  const FeatureActionError({required this.items, required this.message});
  @override
  List<Object?> get props => [items, message];
}
```

### 6. DI (`lib/di/injection.dart`)

Register repository as lazy singleton. Cubits are NOT registered in GetIt.

### 7. Mock (`test/helpers/mocks.dart`)

```dart
class MockFeatureRepository extends Mock implements FeatureRepository {}
class MockFeatureCubit extends MockCubit<FeatureState> implements FeatureCubit {}
```

### 8. Factory (`test/helpers/factories.dart`)

```dart
Feature makeFeature({
  String id = 'feature-1',
  String name = 'Test Feature',
  FeatureStatus status = FeatureStatus.active,
}) => Feature(id: id, name: name, status: status);
```

### 9. JSON fixture (`test/helpers/test_data.dart`)

```dart
Map<String, dynamic> makeFeatureResponseJson({
  List<Map<String, dynamic>>? items,
}) => {
  'feature': {
    'items': items ?? [{'id': 'feature-1', 'name': 'Test Feature', 'status': 'ACTIVE'}],
  },
};
```

### 10. Tests

- **Cubit tests**: `test/blocs/<feature>/<feature>_cubit_test.dart`
- **Repository tests**: `test/data/repositories/<feature>_repository_test.dart`
- Use `mocktail`, `bloc_test`, `flutter_test`
- Test success, error, and `ActionError` paths

## Scope decision

- **App-wide** cubits (multiple screens): `lib/blocs/<feature>/`
- **Screen-scoped** cubits (single screen): `lib/ui/screens/<screen>/cubit/`

## Reference files

Study these canonical implementations before scaffolding:

- Model: `lib/data/models/docker_container.dart`
- Repository: `lib/data/repositories/docker_repository.dart`
- Cubit: `lib/blocs/docker/docker_cubit.dart`
- State: `lib/blocs/docker/docker_state.dart`
- Tests: `test/blocs/docker/docker_cubit_test.dart`

## Verification

After generating all files, run `flutter analyze` and `flutter test`. Both must pass with zero errors.

$ARGUMENTS
