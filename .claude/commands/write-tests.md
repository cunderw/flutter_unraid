# Write Tests

Write tests for existing or new code following project testing conventions.

## Usage

`/project:write-tests <target file or class>`

Provide: the file or class to test and the test type (cubit, repository, model, or widget).

## Shared Rules

- **Framework**: `mocktail` (not mockito) + `bloc_test` + `flutter_test`
- **Mocks**: defined in `test/helpers/mocks.dart` — add new ones there if needed
- **Factories**: defined in `test/helpers/factories.dart` — add new `make*()` helpers if needed
- **JSON fixtures**: defined in `test/helpers/test_data.dart` — add new `make*ResponseJson()` if needed
- **Test directory mirrors `lib/`**: e.g., `lib/blocs/docker/` → `test/blocs/docker/`

## Cubit Tests

Reference: `test/blocs/docker/docker_cubit_test.dart`

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  late MockRepository mockRepo;

  setUp(() { mockRepo = MockRepository(); });

  Cubit buildCubit() => Cubit(mockRepo);

  group('Cubit', () {
    test('initial state is Initial', () {
      expect(buildCubit().state, const Initial());
    });

    group('load', () {
      blocTest<Cubit, State>(
        'emits [Loading, Loaded] on success',
        build: () {
          when(() => mockRepo.getData()).thenAnswer((_) async => [...]);
          return buildCubit();
        },
        act: (cubit) => cubit.load(),
        expect: () => [const Loading(), isA<Loaded>()],
      );

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
    });

    group('Loaded helpers', () {
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

  group('methodName', () {
    test('returns parsed data on success', () async {
      when(() => mockDep.query(any())).thenAnswer(
        (_) async => makeQueryResult(makeResponseJson()),
      );
      final result = await repo.getItems();
      expect(result, hasLength(1));
    });

    test('throws on error', () async {
      when(() => mockDep.query(any())).thenAnswer(
        (_) async => makeErrorQueryResult(),
      );
      expect(() => repo.getItems(), throwsA(isA<OperationException>()));
    });
  });
}
```

## Model Tests

```dart
void main() {
  group('Model', () {
    test('fromJson parses all fields', () {
      final model = Model.fromJson({'id': 'test-1', 'name': 'Test'});
      expect(model.id, 'test-1');
      expect(model.name, 'Test');
    });

    test('fromJson handles null/missing fields', () {
      final model = Model.fromJson({'id': 'test-1'});
      expect(model.optionalField, isNull);
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
  });
}
```

- Use `pumpApp()` for standalone widgets, `pumpAppWithBlocs()` for BLoC-dependent widgets
- Stub `state` property for each test scenario
- Test all sealed state branches: Initial/Loading, Error, Loaded, ActionError

$ARGUMENTS
