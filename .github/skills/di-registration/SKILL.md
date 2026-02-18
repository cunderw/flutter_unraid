---
name: di-registration
description: Ensures new services, repositories, and cubits are properly registered in dependency injection and test helpers. Auto-loads when creating new repositories, cubits, or services to prevent forgotten registrations in injection.dart, mocks.dart, and factories.dart.
user-invokable: false
---

# DI Registration Checklist

When a new repository, service, or cubit is created, ensure all registration points are updated.

## When creating a new Repository

1. **Register in `lib/di/injection.dart`**:
   ```dart
   getIt.registerLazySingleton<NewRepository>(
     () => NewRepository(getIt<GraphQLClientManager>()),
   );
   ```

2. **Add mock in `test/helpers/mocks.dart`**:
   ```dart
   class MockNewRepository extends Mock implements NewRepository {}
   ```

3. **Add test factories in `test/helpers/factories.dart`** if the repository returns a new model type:
   ```dart
   NewModel makeNewModel({String id = 'model-1', ...}) => NewModel(id: id, ...);
   ```

## When creating a new Cubit

1. **No DI registration needed** — cubits are created directly in widget trees via `BlocProvider`
2. **Add mock cubit in `test/helpers/mocks.dart`** (for widget tests):
   ```dart
   class MockNewCubit extends MockCubit<NewState> implements NewCubit {}
   ```
3. **If app-wide cubit** (used across multiple screens): add named parameters (`newCubit:` / `newState:`) to `pumpAppWithBlocs()` in `test/helpers/pump_helpers.dart` so screen tests can provide it.

## When creating a new core service

1. **Register in `lib/di/injection.dart`** as singleton:
   ```dart
   getIt.registerSingleton<NewService>(NewService());
   ```

2. **Add mock in `test/helpers/mocks.dart`**:
   ```dart
   class MockNewService extends Mock implements NewService {}
   ```

## When creating a new Repository (test helpers)

In addition to the production registration above, update `test/helpers/get_it_helpers.dart`:

- Add a new optional parameter to `registerMockRepositories()` for the new repository so screen tests using `resetGetIt()` can register it.

## Registration order in injection.dart

Registration order matters — dependencies must be registered before dependents:

```
1. Core services (FlutterSecureStorage, GraphQLClientManager)
2. Repositories that depend only on core services (AuthRepository)
3. Repositories that depend on GraphQLClientManager (lazy singletons)
```

## Verification

After adding registrations, run `flutter test` to confirm nothing is missing. The most common symptom of a missing registration is:

```
Bad state: GetIt: Object/factory with type X is not registered inside GetIt.
```
