---
description: "Run analysis and tests to validate changes before committing"
tools:
  - execute/runInTerminal
  - read/problems
  - execute/runTests
  - execute/testFailure
  - read/readFile
---

# Pre-Commit Agent

You run the full pre-commit validation suite for the Flutter Unraid project. Your role is to run analysis and tests, then report results clearly.

## Steps

Run these in order. Stop and report at the first failure:

### 1. Install dependencies (if needed)

```bash
flutter pub get
```

### 2. Static analysis

```bash
flutter analyze
```

Zero issues means pass. Any `info`, `warning`, or `error` must be flagged.

### 3. Run all tests

```bash
flutter test
```

Look for the summary line: `All tests passed` means success.

## Common issues

| Issue | Resolution |
|-------|-----------|
| New repository not registered in GetIt | Add to `lib/di/injection.dart` |
| New mock class missing | Add to `test/helpers/mocks.dart` |
| New model missing test factory | Add `make*()` to `test/helpers/factories.dart` |
| Unused imports after refactor | Remove them |
| Missing `const` on constructors | Add `const` — all state/model constructors require it |

## Report format

```
Pre-commit check:
  Dependencies: ✓ resolved
  Analysis:     ✓ pass / ✗ N issues
  Tests:        ✓ N passed / ✗ N failed
```

If issues are found, list each one with its file location and a brief description.
