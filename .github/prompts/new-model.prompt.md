# New Model

Scaffold a new data model class with test factory helpers.

## Inputs

- **Model name** (e.g., `Notification`, `DiskInfo`)
- **Fields** with types, nullability, and defaults
- **Computed getters** (e.g., `isHealthy`, `displayName`) — optional
- **Nested models** (e.g., a model that contains a list of another model) — optional
- **GraphQL JSON path** (e.g., the key path in the API response)

## Output Files

1. `lib/data/models/<model_name>.dart` — model class
2. Update `test/helpers/factories.dart` — add `make<Model>()` and convenience variants

## Model Pattern

Follow `lib/data/models/docker_container.dart` exactly:

```dart
class <Model> {
  final String id;
  final String? optionalField;
  // ... all fields final

  const <Model>({
    required this.id,
    this.optionalField,
    // required for non-nullable, optional for nullable
  });

  // Computed getters
  bool get isActive => state == 'ACTIVE';

  factory <Model>.fromJson(Map<String, dynamic> json) => <Model>(
    id: json['id'] as String,
    optionalField: json['optionalField'] as String?,
    // Use null-safe casts with defaults for non-nullable fields
    // Lists: (json['items'] as List<dynamic>?)?.cast<String>() ?? []
    // Nested: NestedModel.fromJson(json['nested'] as Map<String, dynamic>)
    // Nested lists: (json['items'] as List<dynamic>?)
    //     ?.map((e) => NestedModel.fromJson(e as Map<String, dynamic>))
    //     .toList() ?? []
  );
}
```

## Rules

- `const` constructors always
- `factory fromJson()` — **no `toJson()`** (read-only from API)
- Null-safe JSON parsing with `as Type?` casts and `?? default` fallbacks
- Computed getters for derived state (e.g., `isRunning`, `displayName`)
- Nested models in the same file if tightly coupled, separate file if reusable
- No code generation (no Freezed, no json_serializable)

## Factory Pattern

Add to `test/helpers/factories.dart`:

```dart
<Model> make<Model>({
  String id = '<model>-1',
  String? optionalField = 'default',
  // Sensible defaults for every field
}) => <Model>(
  id: id,
  optionalField: optionalField,
);

// Convenience variants for common states:
<Model> makeActive<Model>({String id = '<model>-1'}) =>
    make<Model>(id: id, state: 'ACTIVE');
<Model> makeInactive<Model>({String id = '<model>-2'}) =>
    make<Model>(id: id, state: 'INACTIVE');
```

Follow the naming convention: `make<Model>()` for the base factory, `make<Adjective><Model>()` for common state variants. Use named parameters with defaults to allow easy overrides in tests.
