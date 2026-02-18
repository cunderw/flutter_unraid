# CLAUDE.md — Flutter Unraid

This file provides context for Claude Code when working in this repository.

## Commands

```bash
flutter pub get          # Install dependencies
flutter test             # Run all tests
flutter analyze          # Lint check
flutter run              # Launch app
```

Always run `flutter analyze` and `flutter test` before considering work complete.

## Architecture

Layered architecture with unidirectional data flow:

```
UI (Screens/Widgets) → Cubits (BLoC) → Repositories → GraphQL Client → Unraid Server
```

- **DI**: `GetIt` in `lib/di/injection.dart` — singletons for core services, lazy singletons for repositories. No `@injectable` annotations; all manual registration. New repos/cubits must be registered here.
- **State management**: Cubits only (not full Blocs). States are **sealed class** hierarchies extending `Equatable` with `final class` leaves.
- **Models**: Hand-written with `const` constructors, `factory fromJson()`, no `toJson` (read-only from API). No code generation.
- **GraphQL**: Raw `graphql` package. Queries/mutations are `static const String` in utility classes (`Queries._()`, `Mutations._()`). Use raw string literals (`r'''...'''`).

## Key Patterns

### Error handling

Every cubit method wraps errors with `AppException.from(e, st)`, logs via `Log.e(_tag, ...)`, and emits an error state. When a mutation fails **and loaded data exists**, emit an `ActionError` variant (e.g., `DockerActionError`) that preserves the data for snackbar-style feedback. Otherwise emit the plain `Error` state. Canonical example: `lib/blocs/docker/docker_cubit.dart`.

### Logging

Use `Log.d/i/w/e()` from `lib/utils/log.dart`. Each class defines `static const _tag = 'ClassName';` and passes it to log calls. Debug for fetches, info for mutations, error for failures.

### State classes

Dart 3 sealed classes. Every feature needs: `Initial`, `Loading`, `Loaded`, `Error`, and optionally `ActionError`. Loaded states include computed getters (e.g., `running`, `stopped` counts). Example: `lib/blocs/docker/docker_state.dart`.

### Screen-scoped cubits

Cubits tightly coupled to a single screen live under that screen's directory (e.g., `lib/ui/screens/container_detail/cubit/container_logs_cubit.dart`). Use `lib/blocs/` only for app-wide or cross-screen cubits.

### GraphQL strings

- Queries: `lib/graphql/queries.dart` — `static const String` in `Queries._()` class.
- Mutations: `lib/graphql/mutations.dart` — `static const String` in `Mutations._()` class.
- When adding a new feature, add both the query/mutation string **and** a matching `make<Type>ResponseJson()` fixture in `test/helpers/test_data.dart`.

### Repositories

- Accept `GraphQLClientManager` via constructor (not getIt lookups).
- Use `FetchPolicy.networkOnly` for queries.
- Parse JSON into models via `fromJson` factories.
- Throw `result.exception!` on GraphQL errors — cubits catch and wrap these.
- Use `_tag` for all Log calls.

### Theme & spacing

- Dark theme with Unraid orange accent (`#FF8C2F`) in `lib/config/theme.dart`.
- 4-point spacing grid via `AppSpacing` constants in `lib/config/spacing.dart`.
- State-to-color mapping via `switch` expressions in `AppColors`.

## Testing

- **Framework**: `mocktail` (NOT mockito) + `bloc_test` + `flutter_test`.
- **Mocks**: `test/helpers/mocks.dart` — one-liner `Mock` classes for all services, repos, and cubits.
- **Factories**: `test/helpers/factories.dart` — `make<Model>()` with named params and defaults; `make<Adjective><Model>()` shortcuts (e.g., `makeRunningContainer()`).
- **JSON fixtures**: `test/helpers/test_data.dart` — `make<Type>ResponseJson()` builders returning raw `Map<String, dynamic>` matching GraphQL response shapes. Wrap with `makeQueryResult()` for success or `makeErrorQueryResult()` for failure stubs.
- **Cubit tests**: Use `blocTest<Cubit, State>()`, group per method, `buildCubit()` helper, `seed:` for pre-loaded state, `verify:` for repo call assertions.
- **Widget tests**: Use `pumpApp()` / `pumpAppWithBlocs()` from `test/helpers/pump_helpers.dart`. Register mock dependencies in GetIt for tests that pump `UnraidApp` directly.
- Test directory mirrors `lib/` structure.

## Conventions

- Dart 3 features throughout: sealed classes, `final class`, switch expressions, pattern matching, records.
- `const` constructors everywhere possible.
- `abstract final class` for utility/constant classes (e.g., `AppSpacing`, `Queries`).
- No code generation for models — all hand-written.
- Private package (`publish_to: "none"`).

## Checklist for new features

1. Model in `lib/data/models/` with `const` constructor, `fromJson`, `Equatable`.
2. Query/mutation string in `lib/graphql/queries.dart` or `mutations.dart`.
3. Repository in `lib/data/repositories/` accepting `GraphQLClientManager`.
4. Cubit + sealed state in `lib/blocs/` (or screen-scoped under `lib/ui/screens/<screen>/cubit/`).
5. Register repository and cubit in `lib/di/injection.dart`.
6. Add `Mock<Type>` in `test/helpers/mocks.dart`.
7. Add `make<Model>()` factory in `test/helpers/factories.dart`.
8. Add `make<Type>ResponseJson()` in `test/helpers/test_data.dart`.
9. Write tests mirroring `lib/` structure under `test/`.
