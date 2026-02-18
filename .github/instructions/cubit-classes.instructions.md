---
applyTo: "**/*_cubit.dart"
---

# Cubit Instructions

## Structure

```dart
class FeatureCubit extends Cubit<FeatureState> {
  static const _tag = 'FeatureCubit';
  final FeatureRepository _repository;

  FeatureCubit(this._repository) : super(const FeatureInitial());
}
```

## Error handling pattern

Every public method must:
1. Emit `Loading` (or keep `Loaded` for mutations).
2. Wrap the body in try/catch.
3. On catch: wrap with `AppException.from(e, st)`, log with `Log.e(_tag, ...)`, emit error state.

```dart
Future<void> fetch() async {
  emit(const FeatureLoading());
  try {
    final data = await _repository.getItems();
    emit(FeatureLoaded(data));
  } catch (e, st) {
    final exception = AppException.from(e, st);
    Log.e(_tag, 'Failed to fetch items', error: exception);
    emit(FeatureError(exception.message));
  }
}
```

## Mutation with ActionError

When a mutation fails **and the cubit already holds loaded data**, emit an `ActionError` that preserves the data so the UI can show a snackbar instead of replacing the screen:

```dart
Future<void> startItem(String id) async {
  final currentState = state;
  try {
    Log.i(_tag, 'Starting item $id');
    await _repository.startItem(id);
    await fetch(); // refresh
  } catch (e, st) {
    final exception = AppException.from(e, st);
    Log.e(_tag, 'Failed to start item $id', error: exception);
    if (currentState is FeatureLoaded) {
      emit(FeatureActionError(items: currentState.items, message: exception.message));
    } else {
      emit(FeatureError(exception.message));
    }
  }
}
```

## Logging

- `Log.d(_tag, ...)` for fetch start
- `Log.i(_tag, ...)` for mutations
- `Log.e(_tag, ..., error: exception)` for failures
