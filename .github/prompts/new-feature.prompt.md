# New Feature (Cubit + State + Test)

Scaffold a new cubit feature with state hierarchy, cubit implementation, and comprehensive tests.

## Inputs

- **Feature name** (e.g., `notifications`, `array`)
- **Model type** (e.g., `Notification`, `ArrayData`)
- **Repository** (e.g., `NotificationRepository`)
- **Load method** on the repo (e.g., `getNotifications()`)
- **Mutation methods** (e.g., `archive(id)`, `delete(id)`) — optional
- **Scope** — `app-wide` (goes in `lib/blocs/<feature>/`) or `screen-scoped` (goes in `lib/ui/screens/<screen>/cubit/`)

## Output Files

1. `<feature>_state.dart` — sealed state class hierarchy
2. `<feature>_cubit.dart` — cubit with load, refresh, and mutation methods
3. `test/blocs/<feature>/<feature>_cubit_test.dart` — full test coverage

## State Pattern

Follow `lib/blocs/docker/docker_state.dart` exactly:

```dart
sealed class <Feature>State extends Equatable {
  const <Feature>State();
  @override
  List<Object?> get props => [];
}

final class <Feature>Initial extends <Feature>State { const <Feature>Initial(); }
final class <Feature>Loading extends <Feature>State { const <Feature>Loading(); }

final class <Feature>Loaded extends <Feature>State {
  final List<Model> items;
  const <Feature>Loaded(this.items);
  // Add computed getters (e.g., running/stopped counts)
  @override
  List<Object?> get props => [items];
}

final class <Feature>Error extends <Feature>State {
  final String message;
  const <Feature>Error(this.message);
  @override
  List<Object?> get props => [message];
}

// Only if mutations exist:
final class <Feature>ActionError extends <Feature>State {
  final List<Model> items;
  final String message;
  const <Feature>ActionError({required this.items, required this.message});
  @override
  List<Object?> get props => [items, message];
}
```

## Cubit Pattern

Follow `lib/blocs/docker/docker_cubit.dart` exactly:

- `static const _tag = '<Feature>Cubit';`
- Constructor takes repository, super starts with `const <Feature>Initial()`
- `load()`: emit Loading → try repo call → emit Loaded; catch → `AppException.from()` + `Log.e()` + emit Error
- `refresh()` delegates to `load()`
- Mutations: try → repo call → `load()`; catch → `_emitActionError()` which preserves loaded data
- `_emitActionError()` checks `state is <Feature>Loaded` or `<Feature>ActionError` to preserve data, otherwise emits `<Feature>Error`

## Test Pattern

Follow `test/blocs/docker/docker_cubit_test.dart` exactly:

- Import `bloc_test`, `flutter_test`, `mocktail`
- `late MockRepository mockRepo;` in `setUp`
- `buildCubit()` helper
- Groups: `load`, each mutation method, `Loaded helpers`
- For each method test both success and error paths
- Use `seed:` for ActionError tests
- Use factories from `test/helpers/factories.dart` — add new `make*()` functions if needed
- Add mock class to `test/helpers/mocks.dart` if the repository mock doesn't exist yet
