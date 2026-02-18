---
applyTo: "**/models/*.dart"
---

# Model Instructions

## Structure

Models are hand-written (no code generation). Every model must have:

1. A `const` constructor with named parameters.
2. A `factory Model.fromJson(Map<String, dynamic> json)` factory constructor.
3. **No** `toJson()` — models are read-only from the API.
4. Extend `Equatable` with `props` override.

```dart
import 'package:equatable/equatable.dart';

class Feature extends Equatable {
  final String id;
  final String name;
  final FeatureStatus status;

  const Feature({
    required this.id,
    required this.name,
    required this.status,
  });

  factory Feature.fromJson(Map<String, dynamic> json) {
    return Feature(
      id: json['id'] as String,
      name: json['name'] as String,
      status: FeatureStatus.fromString(json['status'] as String),
    );
  }

  // Computed getters
  bool get isActive => status == FeatureStatus.active;

  @override
  List<Object?> get props => [id, name, status];
}
```

## Enums

Use Dart 3 enhanced enums with a `fromString` factory:

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

## After creating a model

- Add a `makeFeature()` factory in `test/helpers/factories.dart` with sensible defaults.
- Add a `make<Type>ResponseJson()` in `test/helpers/test_data.dart` matching the GraphQL response shape.
