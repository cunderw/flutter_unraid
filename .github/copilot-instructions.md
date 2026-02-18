# Copilot Instructions — Flutter Unraid

## Architecture

Layered architecture with unidirectional data flow:

```
UI (Screens/Widgets) → Cubits (BLoC) → Repositories → GraphQL Client → Unraid Server
```

- **DI**: `GetIt` in `lib/di/injection.dart` — singletons for core services, lazy singletons for repositories. No `@injectable` annotations; all manual registration.
- **State management**: Cubits only (not full Blocs). States are **sealed class** hierarchies extending `Equatable` with `final class` leaves.
- **Models**: Hand-written with `const` constructors, `factory fromJson()`, no `toJson` (read-only from API).
- **GraphQL**: Raw `graphql` package. Queries/mutations are `static const String` in utility classes (`Queries._()`, `Mutations._()`).

## Key Patterns

### Cubit error handling

Every cubit method wraps errors with `AppException.from()`, logs via `Log.e()`, and emits an error state. When a mutation fails **and loaded data exists**, emit an `ActionError` variant (e.g., `DockerActionError`) that preserves the data for snackbar-style feedback. Otherwise emit the plain `Error` state. See `lib/blocs/docker/docker_cubit.dart` for the canonical example.

### Logging

Use `Log.d/i/w/e()` from `lib/utils/log.dart`. Each class defines `static const _tag = 'ClassName';` and passes it to log calls. Debug for fetches, info for mutations, error for failures.

### State classes

Use Dart 3 sealed classes. Every feature has: `Initial`, `Loading`, `Loaded`, `Error`, and optionally `ActionError`. Loaded states include computed getters (e.g., `running`, `stopped` counts). Example: `lib/blocs/docker/docker_state.dart`.

### Screen-scoped cubits

Cubits tightly coupled to a single screen live under that screen's directory (e.g., `lib/ui/screens/container_detail/cubit/container_logs_cubit.dart`) rather than in `lib/blocs/`. Use `lib/blocs/` for app-wide or cross-screen cubits (docker, auth, system, shares, vms).

### GraphQL strings

- Queries live in `lib/graphql/queries.dart` as `static const String` members of the `Queries._()` class.
- Mutations live in `lib/graphql/mutations.dart` as `static const String` members of the `Mutations._()` class.
- Use raw string literals (`r'''...'''`).
- When adding a new feature, add both the query/mutation string **and** a matching `make<Type>ResponseJson()` fixture in `test/helpers/test_data.dart`.

### Repositories

- Accept `GraphQLClientManager` via constructor
- Use `FetchPolicy.networkOnly` for queries
- Parse JSON into models via `fromJson` factories
- Throw `result.exception!` on GraphQL errors (caught by cubits)
- Use `_tag` for logging

### Theme & spacing

- Dark theme with Unraid orange accent (`#FF8C2F`) in `lib/config/theme.dart`
- 4-point spacing grid via `AppSpacing` constants and pre-built `Widget` gaps in `lib/config/spacing.dart`
- State-to-color mapping via `switch` expressions in `AppColors`

## Testing

- **Framework**: `mocktail` (not mockito) + `bloc_test` + `flutter_test`
- **Mocks**: `test/helpers/mocks.dart` — one-liner `Mock` classes for all services, repos, and cubits
- **Factories**: `test/helpers/factories.dart` — `make<Model>()` with named params and defaults; `make<Adjective><Model>()` shortcuts (e.g., `makeRunningContainer()`)
- **JSON fixtures**: `test/helpers/test_data.dart` — `make<Type>ResponseJson()` builders that return raw `Map<String, dynamic>` matching GraphQL response shapes. Wrap with `makeQueryResult()` for success or `makeErrorQueryResult()` for failure stubs.
- **Cubit tests**: Use `blocTest<Cubit, State>()`, group per method, `buildCubit()` helper, `seed:` for pre-loaded state, `verify:` for repo call assertions
- **Widget tests**: Use `pumpApp()` / `pumpAppWithBlocs()` extensions from `test/helpers/pump_helpers.dart`. Register mock dependencies in GetIt for tests that pump `UnraidApp` directly.
- Test directory mirrors `lib/` structure

### Commands

```bash
flutter pub get          # Install dependencies
flutter test             # Run all tests
flutter analyze          # Lint check
flutter run              # Launch app
```

## Conventions

- Dart 3 features throughout: sealed classes, `final class`, switch expressions, pattern matching, records
- `const` constructors everywhere possible
- `abstract final class` for utility/constant classes (e.g., `AppSpacing`, `Queries`)
- No code generation for models — all hand-written
- GraphQL strings use raw string literals (`r'''...'''`)
- Private package (`publish_to: "none"`)
