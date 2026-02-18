# Run Tests

Run and manage Flutter tests for this project.

## Usage

`/project:run-tests <optional: test file, directory, or test name>`

## Test commands

- **All tests**: `flutter test`
- **Single file**: `flutter test test/blocs/docker/docker_cubit_test.dart`
- **Directory**: `flutter test test/blocs/`
- **By name**: `flutter test --name "emits DockerLoading"`
- **With coverage**: `flutter test --coverage`

## Project test structure

```
test/
├── widget_test.dart                    # App-level smoke test (needs GetIt mocks)
├── blocs/                              # Cubit tests
├── data/
│   ├── models/                         # Model fromJson + getter tests
│   └── repositories/                   # Repository tests with mock dependencies
├── helpers/
│   ├── mocks.dart                      # All mock classes (mocktail)
│   ├── factories.dart                  # make*() test data factories
│   ├── pump_helpers.dart               # pumpApp() / pumpAppWithBlocs() extensions
│   ├── get_it_helpers.dart             # resetGetIt() for widget tests
│   └── test_data.dart                  # Raw JSON fixtures
└── ui/
    ├── screens/                        # Widget tests for screens
    └── widgets/                        # Widget tests for reusable components
```

## Interpreting failures

- **`Bad state: GetIt: Object/factory with type X is not registered`** — Missing mock registration in GetIt. Fix: register mocks before pumping.
- **`MissingStubError`** — A `mocktail` mock method was called without a `when()` stub. Add the missing stub.
- **`Expected: ...` / `Actual: ...`** — State emission mismatch. Check the cubit logic and the `expect:` list.

## When fixing a failing test

1. Run the specific failing test file first to reproduce
2. Read the error output — mocktail errors name the missing stub
3. Check if source code changed and the test needs updating
4. Check if `test/helpers/mocks.dart` or `test/helpers/factories.dart` need new entries
5. Run the full suite after fixing: `flutter test`

$ARGUMENTS
