---
agent: "agent"
description: "Investigate and fix a bug or issue in the Flutter Unraid codebase. Follows a structured diagnosis → fix → verify workflow."
---

# Fix Issue

Diagnose and fix a bug or issue using a structured workflow.

## Inputs

- **Problem** — describe the bug, error message, or unexpected behavior
- **Location** (optional) — file, screen, or feature where it occurs

## Workflow

### 1. Reproduce & understand

- If the problem is a failing test, run it: `flutter test <path>`
- If the problem is an analyzer error, run: `flutter analyze`
- If the problem is a runtime behavior, identify the relevant screen/cubit/repository

### 2. Locate the source

Narrow down which layer is responsible:

| Symptom | Likely layer | Start here |
|---------|-------------|------------|
| Wrong data displayed | Model `fromJson` parsing | `lib/data/models/` |
| Data not loading / GraphQL error | Repository or query string | `lib/data/repositories/`, `lib/graphql/queries.dart` |
| Wrong state transitions | Cubit logic | `lib/blocs/` or screen-scoped `cubit/` |
| UI not reacting to state | Widget `BlocBuilder` | `lib/ui/screens/` or `lib/ui/widgets/` |
| `GetIt: Object not registered` | Missing DI registration | `lib/di/injection.dart` |
| `MissingStubError` in tests | Missing mock stub | `when()` call in the test |
| `Bad state` in tests | GetIt not set up for test | `test/helpers/get_it_helpers.dart` |

### 3. Trace the data flow

Follow the architecture layers to find where things go wrong:

```
UI (BlocBuilder) → Cubit (method call) → Repository (GraphQL query) → Model (fromJson)
```

- Read the cubit method that triggers the issue
- Check if the repository is called correctly
- Verify the GraphQL query/mutation string matches the expected response shape
- Check model `fromJson` handles all fields from the API

### 4. Fix

Apply the minimal change that resolves the issue:

- **Model fix**: update `fromJson` parsing, add null safety, handle missing fields
- **Repository fix**: correct query string reference, fix JSON path traversal
- **Cubit fix**: correct state emission logic, fix error handling pattern
- **Widget fix**: update `BlocBuilder` switch cases for new/changed states
- **Test fix**: add missing stubs, update expected states, add new mock registrations

### 5. Verify

After fixing:

1. Run the specific test: `flutter test <path_to_test>`
2. Run the analyzer: `flutter analyze`
3. Run the full test suite: `flutter test`
4. If the fix involved adding/changing a model, check `test/helpers/factories.dart` and `test/helpers/test_data.dart` are in sync

## Error handling reminders

- Cubits catch errors with `AppException.from(e, st)` and log with `Log.e(_tag, ...)`
- If a mutation fails and loaded data exists, emit `ActionError` (not `Error`)
- Repositories throw `result.exception!` on GraphQL errors — they don't catch

## Common root causes

| Error | Root cause | Fix |
|-------|-----------|-----|
| `type 'Null' is not a subtype of type 'String'` | API field is nullable but model expects non-null | Add null check in `fromJson` or make field nullable |
| `RangeError` | Empty list accessed by index | Add bounds check or handle empty state |
| State not updating after mutation | Cubit doesn't re-fetch after mutation | Add `await fetch()` after successful mutation |
| Snackbar not showing on error | Emitting `Error` instead of `ActionError` | Check `currentState is Loaded` before choosing error type |
| Widget test fails with GetIt error | Mock not registered | Add registration in `setUp` using `getIt.registerLazySingleton` |
| `OperationException` | GraphQL query/mutation syntax error or wrong variable types | Compare query string with API schema |
