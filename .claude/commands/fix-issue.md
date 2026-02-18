# Fix Issue

Diagnose and fix a bug or issue using a structured workflow.

## Usage

`/project:fix-issue <error message, failing test, or description of the bug>`

## Workflow

### Step 1: Reproduce

- **Failing test**: `flutter test <path>`
- **Analyzer error**: `flutter analyze`
- **Runtime bug**: identify the relevant screen/cubit/repository

Capture the full error output before proceeding.

### Step 2: Locate the source

Use the architecture layers to narrow down:

```
UI (Screens/Widgets) → Cubits (BLoC) → Repositories → GraphQL Client → Unraid Server
```

| Error pattern | Check first |
|--------------|------------|
| `type 'Null' is not a subtype of type 'X'` | Model `fromJson` — field is nullable from API |
| `Bad state: GetIt: Object/factory with type X` | `lib/di/injection.dart` — missing registration |
| `MissingStubError: 'methodName'` | Test file — missing `when()` stub |
| `OperationException` | `lib/graphql/queries.dart` or `mutations.dart` — query syntax |
| State not updating | Cubit — missing `emit()` or missing `await fetch()` after mutation |
| `ActionError` not shown as snackbar | Widget — `BlocListener` not handling `ActionError` state |
| `RangeError (index)` | Empty list access — add bounds check |

### Step 3: Trace the data flow

Read the relevant files in order:

1. **Cubit method** that triggers the issue
2. **Repository method** it calls
3. **GraphQL query/mutation** string
4. **Model `fromJson`** that parses the response
5. **Widget** that observes the state

### Step 4: Fix

Apply the minimal correct change. Follow project conventions:

- Cubits: wrap with `AppException.from(e, st)`, log with `Log.e(_tag, ...)`, emit error state
- Mutations: emit `ActionError` (not `Error`) when loaded data exists
- Repositories: throw `result.exception!` on GraphQL errors — don't catch
- Models: `const` constructors, `Equatable`, `fromJson` factory, no `toJson`
- States: sealed class hierarchy, all `final class` with `const` constructors

### Step 5: Verify

1. Run the specific test: `flutter test <path_to_test>`
2. Run the analyzer: `flutter analyze`
3. Run the full test suite: `flutter test`

### Step 6: Check for ripple effects

| Changed | Also update |
|---------|------------|
| Model fields | `test/helpers/factories.dart`, `test/helpers/test_data.dart` |
| Repository signature | Cubit that calls it, mock stubs in tests |
| State class | `BlocBuilder` switch cases in widgets, `expect:` in cubit tests |
| Query/mutation string | `test/helpers/test_data.dart` JSON fixture to match |
| DI registration | `test/widget_test.dart` and any test that uses GetIt |

## Common root causes

| Error | Root cause | Fix |
|-------|-----------|-----|
| `type 'Null' is not a subtype of type 'String'` | API field nullable, model expects non-null | Add null check in `fromJson` or make field nullable |
| `RangeError` | Empty list accessed by index | Add bounds check or handle empty state |
| State not updating after mutation | Cubit doesn't re-fetch | Add `await fetch()` after successful mutation |
| Snackbar not showing on error | Emitting `Error` instead of `ActionError` | Check `currentState is Loaded` before choosing error type |
| Widget test fails with GetIt error | Mock not registered | Add registration in `setUp` |
| `OperationException` | Query syntax error or wrong variable types | Compare query string with API schema |

$ARGUMENTS
