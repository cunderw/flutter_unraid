# New Model

Scaffold a new data model class with test factory helpers.

## Usage

`/project:new-model <model name and fields>`

Provide: model name, fields with types/nullability, computed getters, nested models, and GraphQL JSON path.

## Output Files

1. `lib/data/models/<model_name>.dart` — model class
2. Update `test/helpers/factories.dart` — add `make<Model>()` and convenience variants
3. Update `test/helpers/test_data.dart` — add `make<Model>ResponseJson()`

## Model Pattern

Follow `lib/data/models/docker_container.dart`:

```dart
import 'package:equatable/equatable.dart';

class Model extends Equatable {
  final String id;
  final String? optionalField;

  const Model({required this.id, this.optionalField});

  bool get isActive => state == 'ACTIVE';

  factory Model.fromJson(Map<String, dynamic> json) => Model(
    id: json['id'] as String,
    optionalField: json['optionalField'] as String?,
  );

  @override
  List<Object?> get props => [id, optionalField];
}
```

## Rules

- `const` constructors always
- `factory fromJson()` — **no `toJson()`** (read-only from API)
- Null-safe JSON parsing with `as Type?` casts and `?? default` fallbacks
- Computed getters for derived state (e.g., `isRunning`, `displayName`)
- Extend `Equatable` with `props` override
- Enhanced enums with `fromString` factory for status/type fields
- No code generation (no Freezed, no json_serializable)

## Enum Pattern

```dart
enum FeatureStatus {
  active,
  inactive,
  unknown;

  factory FeatureStatus.fromString(String value) {
    return FeatureStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => FeatureStatus.unknown,
    );
  }
}
```

## Factory Pattern

Add to `test/helpers/factories.dart`:

```dart
Model makeModel({
  String id = 'model-1',
  String? optionalField = 'default',
}) => Model(id: id, optionalField: optionalField);

Model makeActiveModel({String id = 'model-1'}) =>
    makeModel(id: id, state: 'ACTIVE');
```

## JSON Fixture Pattern

Add to `test/helpers/test_data.dart`:

```dart
Map<String, dynamic> makeModelResponseJson({
  List<Map<String, dynamic>>? items,
}) => {
  'model': {
    'items': items ?? [{'id': 'model-1', 'name': 'Test', 'status': 'ACTIVE'}],
  },
};
```

$ARGUMENTS
