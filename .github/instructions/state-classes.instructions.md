---
applyTo: "**/*_state.dart"
---

# State Class Instructions

State files use Dart 3 sealed-class hierarchies extending `Equatable`.

## Required structure

```dart
import 'package:equatable/equatable.dart';

sealed class FeatureState extends Equatable {
  const FeatureState();
  @override
  List<Object?> get props => [];
}

final class FeatureInitial extends FeatureState {
  const FeatureInitial();
}

final class FeatureLoading extends FeatureState {
  const FeatureLoading();
}

final class FeatureLoaded extends FeatureState {
  final List<Model> items;
  const FeatureLoaded(this.items);

  // Add computed getters here (counts, filters, etc.)

  @override
  List<Object?> get props => [items];
}

final class FeatureError extends FeatureState {
  final String message;
  const FeatureError(this.message);
  @override
  List<Object?> get props => [message];
}
```

## Rules

- Always use `sealed class` for the base, `final class` for each leaf.
- Every class must have a `const` constructor.
- Every class must override `props` for Equatable.
- Loaded states should include computed getters where useful (e.g., `running`, `stopped` counts).
- If the feature has mutations, add an `ActionError` variant that preserves the loaded data:

```dart
final class FeatureActionError extends FeatureState {
  final List<Model> items;
  final String message;
  const FeatureActionError({required this.items, required this.message});
  @override
  List<Object?> get props => [items, message];
}
```
