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

## Widget tests

### Choosing a pump helper

| Scenario | Helper |
|----------|--------|
| Standalone widget, no cubit dependency | `pumpApp(widget)` |
| Screen consuming app-wide cubits (Docker, Auth, System, VM, Shares) | `pumpAppWithBlocs(widget, dockerCubit: mock, dockerState: state)` |
| Screen-scoped cubit not built into `pumpAppWithBlocs` | `pumpAppWithBlocs(widget, providers: [BlocProvider<MyCubit>.value(value: mock)])` |
| Screen that creates its own cubits via `BlocProvider` + GetIt | `pumpApp(widget)` with `resetGetIt()` + `registerMockRepositories()` in `setUp` |

### Stubbing async methods on mock cubits

Any mock cubit method called during widget interaction **must** be stubbed to return a `Future`, otherwise mocktail returns `null` and the test throws `type 'Null' is not a subtype of type 'Future<void>'`:

```dart
setUp(() {
  mockCubit = MockContainerLogsCubit();
  when(() => mockCubit.load()).thenAnswer((_) async {});
  when(() => mockCubit.refresh()).thenAnswer((_) async {});
});
```

### `pump()` vs `pumpAndSettle()`

- **`pump()`** — for states with infinite animations (e.g., `CircularProgressIndicator` in Loading states). `pumpAndSettle()` will time out.
- **`pumpAndSettle()`** — for states that reach a steady frame (Loaded, Error, Initial).

### Test each sealed state variant

Widget tests should cover rendering for every state branch: `Initial`, `Loading`, `Loaded`, empty `Loaded`, `Error`, and `ActionError` (if applicable).

### Scrollable content

For widgets rendered below the visible viewport, scroll first:

```dart
await tester.scrollUntilVisible(find.byType(MyWidget), 200);
```

### Example: screen-scoped cubit widget test

```dart
void main() {
  late MockFeatureCubit mockCubit;

  setUp(() {
    mockCubit = MockFeatureCubit();
    when(() => mockCubit.load()).thenAnswer((_) async {});
  });

  Future<void> pumpWidget(WidgetTester tester, {required FeatureState state}) async {
    when(() => mockCubit.state).thenReturn(state);
    await tester.pumpAppWithBlocs(
      const FeatureSection(),
      providers: [BlocProvider<FeatureCubit>.value(value: mockCubit)],
    );
  }

  group('FeatureSection', () {
    testWidgets('shows loading indicator in Loading state', (tester) async {
      await pumpWidget(tester, state: const FeatureLoading());
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error in Error state', (tester) async {
      await pumpWidget(tester, state: const FeatureError('fail'));
      await tester.pumpAndSettle();
      expect(find.text('fail'), findsOneWidget);
    });

    testWidgets('shows data in Loaded state', (tester) async {
      await pumpWidget(tester, state: FeatureLoaded([makeItem()]));
      await tester.pumpAndSettle();
      expect(find.text('Item 1'), findsOneWidget);
    });
  });
}
```

## Naming conventions

- Group by method name for cubits: `group('fetch', () { ... })`
- Group by widget name for widgets: `group('FeatureSection', () { ... })`
- Cubit test descriptions: `'emits [Loading, Loaded] on success'`, `'emits [Loading, Error] on failure'`
- Widget test descriptions: `'displays X when Y'`, `'shows loading indicator in Loading state'`
- Use `seed:` for pre-loaded state tests, `verify:` for repo call assertions
