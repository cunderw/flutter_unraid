---
name: fix-issue
description: Diagnoses and fixes bugs or issues in the Flutter Unraid codebase. Use when the user reports a bug, error, failing test, or unexpected behavior. Follows a structured reproduce → locate → trace → fix → verify workflow.
argument-hint: "[error message, failing test, or description of the bug]"
---

# Fix Issue

Diagnose and fix bugs using a structured workflow.

## Step 1: Reproduce

Reproduce the problem to confirm it and collect error details.

- **Failing test**: Run the specific test file:
  ```bash
  flutter test test/path/to/failing_test.dart
  ```

- **Analyzer error**: Run static analysis:
  ```bash
  flutter analyze
  ```

- **Runtime / behavioral bug**: Identify the screen or feature, then find the corresponding cubit and repository.

Capture the full error output before proceeding.

## Step 2: Locate the source

Use the error message and architecture layers to narrow down the source:

```
UI (Screens/Widgets) → Cubits (BLoC) → Repositories → GraphQL Client → Unraid Server
```

**Quick diagnosis table:**

| Error pattern | Check first |
|--------------|------------|
| `type 'Null' is not a subtype of type 'X'` | Model `fromJson` — field is nullable from API |
| `Bad state: GetIt: Object/factory with type X` | `lib/di/injection.dart` — missing registration |
| `MissingStubError: 'methodName'` | Test file — missing `when()` stub |
| `OperationException` | `lib/graphql/queries.dart` or `mutations.dart` — query syntax |
| State not updating | Cubit — missing `emit()` or missing `await fetch()` after mutation |
| `ActionError` not shown as snackbar | Widget — `BlocListener` not handling `ActionError` state |
| `RangeError (index)` | Empty list access — add bounds check |

## Step 3: Trace the data flow

Read the relevant files in order to understand what's happening:

1. **Cubit method** that triggers the issue (`lib/blocs/` or screen-scoped `cubit/`)
2. **Repository method** it calls (`lib/data/repositories/`)
3. **GraphQL query/mutation** string (`lib/graphql/queries.dart` or `mutations.dart`)
4. **Model `fromJson`** that parses the response (`lib/data/models/`)
5. **Widget** that observes the state (`lib/ui/screens/` or `lib/ui/widgets/`)

## Step 4: Fix

Apply the minimal correct change. Follow project conventions:

### Error handling conventions
- Cubits: wrap with `AppException.from(e, st)`, log with `Log.e(_tag, ...)`, emit error state
- Mutations: emit `ActionError` (not `Error`) when loaded data exists — preserves UI
- Repositories: throw `result.exception!` on GraphQL errors — don't catch

### Model conventions
- `const` constructors, `Equatable`, `fromJson` factory, no `toJson`
- Handle nullable API fields safely in `fromJson`

### State conventions
- Sealed class hierarchy: `Initial`, `Loading`, `Loaded`, `Error`, optionally `ActionError`
- All classes `final class` with `const` constructors

## Step 5: Verify

After fixing, run verification in this order:

1. **Specific test** (if the issue was a test failure):
   ```bash
   flutter test test/path/to/fixed_test.dart
   ```

2. **Static analysis**:
   ```bash
   flutter analyze
   ```

3. **Full test suite**:
   ```bash
   flutter test
   ```

Report results:
```
Fix verification:
  Target test: ✓ pass / ✗ fail
  Analysis:    ✓ pass / ✗ N issues
  Full suite:  ✓ N passed / ✗ N failed
```

## Step 6: Check for ripple effects

If the fix changed any of these, ensure dependent files are updated:

| Changed | Also update |
|---------|------------|
| Model fields | `test/helpers/factories.dart`, `test/helpers/test_data.dart` |
| Repository signature | Cubit that calls it, mock stubs in tests |
| State class | `BlocBuilder` switch cases in widgets, `expect:` in cubit tests |
| Query/mutation string | `test/helpers/test_data.dart` JSON fixture to match |
| DI registration | `test/widget_test.dart` and any test that uses GetIt |

## Common mistakes to avoid

- Using `Error` state when `ActionError` should be used (loses loaded data)
- Forgetting `await fetch()` after a successful mutation in cubit
- Not adding `const` to new state class constructors
- Stubbing with `thenReturn` when the method is async (use `thenAnswer`)
- Editing `test_data.dart` JSON without matching the actual GraphQL response shape
