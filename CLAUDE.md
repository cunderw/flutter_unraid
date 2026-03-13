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

### Directory structure

```
lib/
├── app.dart                     # UnraidApp root widget (theme switching via SettingsCubit)
├── main.dart                    # Entry point
├── blocs/                       # App-wide Cubits (auth, docker, system, vms, shares, notifications, settings)
├── config/
│   ├── theme.dart               # unraidDarkTheme / unraidLightTheme, AppColors, status colors
│   └── spacing.dart             # AppSpacing constants + pre-built Widget gaps (4-point grid)
├── data/
│   ├── models/                  # DockerContainer, SystemInfo, VmDomain, Share, Notification, etc.
│   └── repositories/            # One file per domain; accept GraphQLClientManager via constructor
├── di/
│   └── injection.dart           # All GetIt registrations in one place
├── graphql/
│   ├── client.dart              # GraphQLClientManager
│   ├── queries.dart             # Queries._() class with static const String members
│   └── mutations.dart           # Mutations._() class with static const String members
├── ui/
│   ├── screens/                 # One directory per screen; screen-scoped cubits live under cubit/
│   └── widgets/                 # Reusable components: cards/, data_display/, feedback/, inputs/, layout/
└── utils/
    ├── log.dart                 # Log.d/i/w/e()
    ├── app_exception.dart       # AppException.from() wrapper
    ├── constants.dart           # App constants and storage keys
    ├── formatters.dart          # Byte, uptime, temperature, state formatters
    └── url_helper.dart          # In-app vs external browser helper

test/
├── blocs/                       # Cubit unit tests
├── data/
│   ├── models/                  # Model fromJson tests
│   └── repositories/            # Repository unit tests
├── helpers/
│   ├── mocks.dart               # Mock classes (one-liner)
│   ├── factories.dart           # make<Model>() factories
│   ├── test_data.dart           # make<Type>ResponseJson() + makeQueryResult() / makeErrorQueryResult()
│   ├── pump_helpers.dart        # pumpApp() / pumpAppWithBlocs()
│   └── get_it_helpers.dart      # resetGetIt() for test isolation
└── ui/                          # Widget tests mirroring lib/ui/
```

## Key Patterns

### Error handling

Every cubit method wraps errors with `AppException.from(e, st)`, logs via `Log.e(_tag, ...)`, and emits an error state. When a mutation fails **and loaded data exists**, emit an `ActionError` variant (e.g., `DockerActionError`) that preserves the data for snackbar-style feedback. Otherwise emit the plain `Error` state. Canonical example: `lib/blocs/docker/docker_cubit.dart`.

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

Future<void> startItem(String id) async {
  final currentState = state;
  try {
    Log.i(_tag, 'Starting item $id');
    await _repository.startItem(id);
    await fetch();
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

### Logging

Use `Log.d/i/w/e()` from `lib/utils/log.dart`. Each class defines `static const _tag = 'ClassName';` and passes it to log calls.

- `Log.d(_tag, ...)` — query/fetch start (debug, stripped from release)
- `Log.i(_tag, ...)` — mutation start (info)
- `Log.w(_tag, ...)` — warnings
- `Log.e(_tag, ..., error: exception)` — failures with exception + stackTrace

### State classes

Dart 3 sealed classes. Every feature needs: `Initial`, `Loading`, `Loaded`, `Error`, and optionally `ActionError`. Loaded states include computed getters (e.g., `running`, `stopped` counts). Example: `lib/blocs/docker/docker_state.dart`.

```dart
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
  // Add computed getters (counts, filters, etc.)
  int get activeCount => items.where((i) => i.isActive).length;
  @override
  List<Object?> get props => [items];
}

final class FeatureError extends FeatureState {
  final String message;
  const FeatureError(this.message);
  @override
  List<Object?> get props => [message];
}

// Only needed when feature has mutations
final class FeatureActionError extends FeatureState {
  final List<Model> items;
  final String message;
  const FeatureActionError({required this.items, required this.message});
  @override
  List<Object?> get props => [items, message];
}
```

### Screen-scoped cubits

Cubits tightly coupled to a single screen live under that screen's directory (e.g., `lib/ui/screens/container_detail/cubit/container_logs_cubit.dart`). Use `lib/blocs/` only for app-wide or cross-screen cubits.

### GraphQL strings

- Queries: `lib/graphql/queries.dart` — `static const String` in `Queries._()` class.
- Mutations: `lib/graphql/mutations.dart` — `static const String` in `Mutations._()` class.
- Always use raw string literals: `r'''...'''`.
- When adding a new feature, add both the query/mutation string **and** a matching `make<Type>ResponseJson()` fixture in `test/helpers/test_data.dart`.

### Repositories

```dart
class FeatureRepository {
  static const _tag = 'FeatureRepository';
  final GraphQLClientManager _client;

  FeatureRepository(this._client);

  Future<List<Feature>> getItems() async {
    Log.d(_tag, 'Fetching items');
    final result = await _client.query(
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

Rules:
- Accept `GraphQLClientManager` via constructor (not getIt lookups).
- Use `FetchPolicy.networkOnly` for queries.
- Parse JSON into models via `fromJson` factories.
- Throw `result.exception!` on GraphQL errors — cubits catch and wrap these.
- Use `_tag` for all Log calls.

### Models

```dart
class Feature extends Equatable {
  final String id;
  final String name;
  final FeatureStatus status;

  const Feature({required this.id, required this.name, required this.status});

  factory Feature.fromJson(Map<String, dynamic> json) {
    return Feature(
      id: json['id'] as String,
      name: json['name'] as String,
      status: FeatureStatus.fromString(json['status'] as String),
    );
  }

  bool get isActive => status == FeatureStatus.active;

  @override
  List<Object?> get props => [id, name, status];
}

enum FeatureStatus {
  active, inactive, unknown;

  factory FeatureStatus.fromString(String value) {
    return FeatureStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => FeatureStatus.unknown,
    );
  }
}
```

### Theme & spacing

- Dark theme with Unraid orange accent (`#FF8C2F`) in `lib/config/theme.dart`.
- 4-point spacing grid via `AppSpacing` constants + pre-built Widget gaps in `lib/config/spacing.dart`.
- State-to-color mapping via `switch` expressions in `AppColors`: `forContainerState()`, `forVmState()`, `forArrayState()`, `forDiskStatus()`.
- Spacing levels: `xxxs`=2, `xxs`=4, `xs`=6, `sm`=8, `md`=12, `lg`=16, `xl`=20, `xxl`=24, `xxxl`=32, `xxxxl`=48.
- Pre-built gaps: `AppSpacing.verticalXs`, `AppSpacing.horizontalLg`, etc.

## Testing

- **Framework**: `mocktail` (NOT mockito) + `bloc_test` + `flutter_test`.
- **Mocks**: `test/helpers/mocks.dart` — one-liner `Mock` classes for all services, repos, and cubits.
- **Factories**: `test/helpers/factories.dart` — `make<Model>()` with named params and defaults; `make<Adjective><Model>()` shortcuts (e.g., `makeRunningContainer()`).
- **JSON fixtures**: `test/helpers/test_data.dart` — `make<Type>ResponseJson()` builders returning raw `Map<String, dynamic>` matching GraphQL response shapes. Wrap with `makeQueryResult()` for success or `makeErrorQueryResult()` for failure stubs.
- **Cubit tests**: Use `blocTest<Cubit, State>()`, group per method, `buildCubit()` helper, `seed:` for pre-loaded state, `verify:` for repo call assertions.
- **Widget tests**: Use `pumpApp()` / `pumpAppWithBlocs()` from `test/helpers/pump_helpers.dart`. Register mock dependencies in GetIt for tests that pump `UnraidApp` directly.
- **GetIt isolation**: Call `resetGetIt()` from `test/helpers/get_it_helpers.dart` in `setUp`/`tearDown`.
- Test directory mirrors `lib/` structure.

### Cubit test structure

```dart
void main() {
  late MockFeatureRepository mockRepository;
  FeatureCubit buildCubit() => FeatureCubit(mockRepository);

  setUp(() {
    mockRepository = MockFeatureRepository();
  });

  group('fetch', () {
    blocTest<FeatureCubit, FeatureState>(
      'emits [Loading, Loaded] on success',
      setUp: () {
        when(() => mockRepository.getItems()).thenAnswer((_) async => [makeItem()]);
      },
      build: buildCubit,
      act: (cubit) => cubit.fetch(),
      expect: () => [
        const FeatureLoading(),
        isA<FeatureLoaded>().having((s) => s.items.length, 'count', 1),
      ],
      verify: (_) => verify(() => mockRepository.getItems()).called(1),
    );
  });
}
```

### Repository test structure

Stub the GraphQL client's `query()` or `mutate()` with `makeQueryResult()` + raw JSON from `test_data.dart`:

```dart
when(() => mockClient.query(any())).thenAnswer(
  (_) async => makeQueryResult(makeContainersResponseJson()),
);
```

### Widget test pump helper selection

| Scenario | Helper |
|----------|--------|
| Standalone widget, no cubit dependency | `pumpApp(widget)` |
| Screen consuming app-wide cubits | `pumpAppWithBlocs(widget, dockerCubit: mock, ...)` |
| Screen-scoped cubit not in `pumpAppWithBlocs` | `pumpAppWithBlocs(widget, providers: [BlocProvider<MyCubit>.value(value: mock)])` |
| Screen that creates its own cubits via `BlocProvider` + GetIt | `pumpApp(widget)` with `resetGetIt()` + repository mocks in `setUp` |

### Widget test rules

- Stub all async mock cubit methods with `.thenAnswer((_) async {})` — returning `null` will throw.
- Use `pump()` for states with infinite animations (e.g., `CircularProgressIndicator`); use `pumpAndSettle()` for steady states (Loaded, Error).
- Cover every sealed state variant: `Initial`, `Loading`, `Loaded`, empty `Loaded`, `Error`, and `ActionError` where applicable.
- For content below the viewport: `await tester.scrollUntilVisible(find.byType(MyWidget), 200)`.

### Test naming conventions

- Group by method for cubits: `group('fetch', () { ... })`
- Group by widget for widgets: `group('FeatureSection', () { ... })`
- Cubit descriptions: `'emits [Loading, Loaded] on success'`, `'emits [Loading, Error] on failure'`
- Widget descriptions: `'shows loading indicator in Loading state'`, `'displays data in Loaded state'`

## Conventions

- Dart 3 features throughout: sealed classes, `final class`, switch expressions, pattern matching, records.
- `const` constructors everywhere possible.
- `abstract final class` for utility/constant classes (e.g., `AppSpacing`, `Queries`).
- No code generation for models — all hand-written.
- Private package (`publish_to: "none"`).

## Checklist for new features

1. Model in `lib/data/models/` with `const` constructor, `fromJson`, `Equatable`, and enums with `fromString`.
2. Query/mutation string in `lib/graphql/queries.dart` or `mutations.dart` using `r'''...'''`.
3. Repository in `lib/data/repositories/` accepting `GraphQLClientManager`; register as lazy singleton in `lib/di/injection.dart`.
4. Cubit + sealed state in `lib/blocs/` (or screen-scoped under `lib/ui/screens/<screen>/cubit/`); register cubit in `lib/di/injection.dart`.
5. Add `Mock<Type>` in `test/helpers/mocks.dart`.
6. Add `make<Model>()` factory in `test/helpers/factories.dart`.
7. Add `make<Type>ResponseJson()` in `test/helpers/test_data.dart`.
8. Write cubit, repository, and widget tests mirroring `lib/` structure under `test/`.
