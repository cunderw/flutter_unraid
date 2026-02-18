# Write Tests

Write tests for existing or new code following the project's testing conventions.

## Inputs

- **Target** — the file or class to test (e.g., `lib/blocs/docker/docker_cubit.dart`, `lib/data/models/share.dart`)
- **Test type** — `cubit`, `repository`, `model`, or `widget`

## Shared Rules

- **Framework**: `mocktail` (not mockito) + `bloc_test` + `flutter_test`
- **Mocks**: defined in `test/helpers/mocks.dart` — add new ones there if needed
- **Factories**: defined in `test/helpers/factories.dart` — add new `make*()` helpers if needed
- **Test directory mirrors `lib/`**: e.g., `lib/blocs/docker/` → `test/blocs/docker/`
- **Run**: `flutter test` for all, `flutter test <path>` for a specific file

## Cubit Tests

Reference: `test/blocs/docker/docker_cubit_test.dart`

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_unraid/blocs/<feature>/<feature>_cubit.dart';
import 'package:flutter_unraid/blocs/<feature>/<feature>_state.dart';
import '../../helpers/factories.dart';
import '../../helpers/mocks.dart';

void main() {
  late MockRepository mockRepo;

  setUp(() { mockRepo = MockRepository(); });

  Cubit buildCubit() => Cubit(mockRepo);

  group('Cubit', () {
    test('initial state is Initial', () {
      expect(buildCubit().state, const Initial());
    });

    group('load', () {
      // SUCCESS: stub repo → act → expect [Loading, Loaded]
      blocTest<Cubit, State>(
        'emits [Loading, Loaded] on success',
        build: () {
          when(() => mockRepo.getData()).thenAnswer((_) async => [...]);
          return buildCubit();
        },
        act: (cubit) => cubit.load(),
        expect: () => [const Loading(), isA<Loaded>()],
      );

      // FAILURE: stub repo to throw → expect [Loading, Error]
      blocTest<Cubit, State>(
        'emits [Loading, Error] on failure',
        build: () {
          when(() => mockRepo.getData()).thenThrow(Exception('fail'));
          return buildCubit();
        },
        act: (cubit) => cubit.load(),
        expect: () => [const Loading(), isA<Error>()],
      );
    });

    group('mutation', () {
      // SUCCESS: stub mutation + load → expect [Loading, Loaded]
      // + verify: mutation called with correct args

      // ACTION ERROR: seed with Loaded state → stub mutation to throw
      // → expect [ActionError] (preserves data)
      blocTest<Cubit, State>(
        'emits ActionError when fails and state is Loaded',
        seed: () => Loaded([makeItem()]),
        build: () {
          when(() => mockRepo.mutate(any())).thenThrow(Exception('fail'));
          return buildCubit();
        },
        act: (cubit) => cubit.mutate('id'),
        expect: () => [isA<ActionError>()],
      );

      // ERROR: no seed (initial state) → stub mutation to throw
      // → expect [Error] (no data to preserve)
    });

    group('Loaded helpers', () {
      // Test computed getters on the Loaded state directly
      test('counts are correct', () {
        final state = Loaded([makeActive(), makeInactive()]);
        expect(state.activeCount, 1);
      });
    });
  });
}
```

### Key patterns

- `buildCubit()` helper function for consistent construction
- `when().thenAnswer()` for async success, `when().thenThrow()` for failure
- Use `isA<State>().having((s) => s.field, 'label', value)` for property assertions
- `seed:` parameter to pre-load state for mutation error tests
- `verify:` callback to assert repo method calls with `.called(1)`
- Use `any()` and `any(named: 'paramName')` for flexible matching
- Group tests by method name

## Repository Tests

Reference: `test/data/repositories/auth_repository_test.dart`

```dart
void main() {
  late MockDependency mockDep;
  late Repository repo;

  setUp(() {
    mockDep = MockDependency();
    repo = Repository(mockDep);
  });

  group('Repository', () {
    group('methodName', () {
      test('returns parsed data on success', () async { ... });
      test('throws on error', () async { ... });
      // Test edge cases: null fields, empty lists, missing keys
    });
  });
}
```

### Key patterns

- Instantiate the real repository with mock dependencies
- Test return values, not state emissions
- Test both success paths and exception propagation
- Test boundary conditions (null, empty, missing data)

## Model Tests

Test `fromJson` parsing and computed getters:

```dart
void main() {
  group('Model', () {
    test('fromJson parses all fields', () {
      final model = Model.fromJson({
        'id': 'test-1',
        'name': 'Test',
        // full JSON fixture
      });
      expect(model.id, 'test-1');
      expect(model.name, 'Test');
    });

    test('fromJson handles null/missing fields', () {
      final model = Model.fromJson({'id': 'test-1'});
      expect(model.optionalField, isNull);
      expect(model.listField, isEmpty);
    });

    test('computed getter returns correct value', () {
      final model = makeModel(state: 'ACTIVE');
      expect(model.isActive, isTrue);
    });
  });
}
```

## Widget Tests

Reference: `test/helpers/pump_helpers.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';
import '../../helpers/pump_helpers.dart';

void main() {
  late MockCubit mockCubit;

  setUp(() { mockCubit = MockCubit(); });

  group('ScreenWidget', () {
    testWidgets('shows loading indicator in Loading state', (tester) async {
      when(() => mockCubit.state).thenReturn(const Loading());
      await tester.pumpAppWithBlocs(
        const ScreenWidget(),
        providers: [BlocProvider<Cubit>.value(value: mockCubit)],
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error display in Error state', (tester) async {
      when(() => mockCubit.state).thenReturn(const Error('msg'));
      // ...pump and assert
    });

    testWidgets('shows data in Loaded state', (tester) async {
      when(() => mockCubit.state).thenReturn(Loaded([makeItem()]));
      // ...pump and assert content renders
    });
  });
}
```

### Key patterns

- Use `pumpApp(widget)` for standalone widgets, `pumpAppWithBlocs(widget, providers: [...])` for BLoC-dependent widgets
- Mock cubits use `MockCubit<State>` from `bloc_test` (defined in `test/helpers/mocks.dart`)
- Stub `state` property for each test scenario
- Test all sealed state branches: Initial/Loading, Error, Loaded, ActionError
- For tests pumping `UnraidApp` directly, register mock dependencies in GetIt (see `test/widget_test.dart`)
