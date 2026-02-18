---
applyTo: "**/*_test.dart"
---

# Test File Instructions

## Framework

Use `mocktail` (NOT mockito), `bloc_test`, and `flutter_test`.

## Cubit tests

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  late MockFeatureRepository mockRepository;
  late FeatureCubit buildCubit() => FeatureCubit(mockRepository);

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
      verify: (_) {
        verify(() => mockRepository.getItems()).called(1);
      },
    );
  });
}
```

## Test helpers

- **Mocks**: Import from `test/helpers/mocks.dart` — one-liner `Mock` classes.
- **Model factories**: Import from `test/helpers/factories.dart` — `make<Model>()` with named params, `make<Adj><Model>()` shortcuts.
- **JSON fixtures**: Import from `test/helpers/test_data.dart` — `make<Type>ResponseJson()` builders for raw GraphQL responses, `makeQueryResult()` / `makeErrorQueryResult()` for wrapping into `QueryResult`.
- **Widget pumping**: Use `pumpApp()` / `pumpAppWithBlocs()` from `test/helpers/pump_helpers.dart`.
- **GetIt in tests**: Use `resetGetIt()` from `test/helpers/get_it_helpers.dart` in setUp/tearDown.

## Repository tests

Stub the GraphQL client's `query()` or `mutate()` method using `makeQueryResult()` with raw JSON from `test_data.dart`:

```dart
when(() => mockClient.query(any())).thenAnswer(
  (_) async => makeQueryResult(makeContainersResponseJson()),
);
```

## Naming conventions

- Group by method name: `group('fetch', () { ... })`
- Test descriptions: `'emits [Loading, Loaded] on success'`, `'emits [Loading, Error] on failure'`
- Use `seed:` for pre-loaded state tests, `verify:` for repo call assertions
