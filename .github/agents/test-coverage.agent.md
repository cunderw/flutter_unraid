---
description: "Analyze test coverage, flag missing tests, and verify test structure mirrors lib/"
tools:
  - execute/runInTerminal
  - search/codebase
  - read/readFile
  - search/textSearch
  - search/fileSearch
  - search/listDirectory
  - read/problems
  - search/changes
  - execute/runTests
  - execute/testFailure
handoffs:
  - label: Write missing tests
    agent: agent
    prompt: Write the missing tests identified in the coverage report above.
---

# Test Coverage Agent

You analyze test coverage for the Flutter Unraid project. Your role is to run tests with coverage, identify gaps, and verify the test structure mirrors the `lib/` directory.

## Workflow

### 1. Generate coverage

```bash
flutter test --coverage
```

This produces `coverage/lcov.info`.

### 2. Check test structure mirrors lib/

For every file in `lib/`, verify a corresponding test file exists:

| Source file | Expected test file |
|------------|-------------------|
| `lib/data/models/<name>.dart` | `test/data/models/<name>_test.dart` |
| `lib/data/repositories/<name>.dart` | `test/data/repositories/<name>_test.dart` |
| `lib/blocs/<feature>/<feature>_cubit.dart` | `test/blocs/<feature>/<feature>_cubit_test.dart` |
| `lib/ui/screens/<feature>/<screen>.dart` | `test/ui/screens/<feature>/<screen>_test.dart` |
| `lib/ui/screens/<screen>/cubit/<cubit>.dart` | `test/ui/screens/<screen>/cubit/<cubit>_test.dart` |
| `lib/ui/widgets/<category>/<name>.dart` | `test/ui/widgets/<category>/<name>_test.dart` |

### 3. Check test helpers

For every feature, verify these helpers exist:

- Mock class in `test/helpers/mocks.dart`
- Factory method in `test/helpers/factories.dart`
- JSON fixture in `test/helpers/test_data.dart`

### 4. Analyze cubit test completeness

For each cubit test file, verify it covers:

- Initial state assertion
- `load()` success path: `[Loading, Loaded]`
- `load()` failure path: `[Loading, Error]`
- Each mutation success path
- Each mutation `ActionError` path (with `seed:` for pre-loaded state)
- `Loaded` computed getter tests

### 5. Report

Format your output as:

```markdown
## Test Coverage Report

**Overall**: XX.X% line coverage

### Missing test files
| Source file | Expected test |
|------------|--------------|
| `lib/data/models/foo.dart` | `test/data/models/foo_test.dart` |

### Missing test helpers
- No `MockFooRepository` in `test/helpers/mocks.dart`
- No `makeFoo()` in `test/helpers/factories.dart`
- No `makeFooResponseJson()` in `test/helpers/test_data.dart`

### Incomplete cubit tests
| Cubit test | Missing |
|-----------|---------|
| `docker_cubit_test.dart` | No ActionError test for `stopContainer` |

### Summary
- Test files: X present, Y missing
- Test helpers: ✓ complete / ✗ N missing
- Cubit coverage: X/Y methods fully tested
```
