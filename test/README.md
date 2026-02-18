# Test Suite

This directory contains comprehensive tests for the Flutter Unraid app.

## Running Tests

To run all tests:
```bash
flutter test
```

To run tests with coverage:
```bash
flutter test --coverage
```

To run a specific test file:
```bash
flutter test test/blocs/auth/auth_cubit_test.dart
```

## Test Structure

### Cubit Tests (`test/blocs/`)
Tests for all state management cubits using `bloc_test`:
- **AuthCubit** - Authentication flow (login, logout, auto-login)
- **DockerCubit** - Container management operations
- **SystemCubit** - System info and array state management
- **VmCubit** - VM lifecycle operations
- **SharesCubit** - Share data loading

### Repository Tests (`test/data/repositories/`)
Tests for data layer repositories:
- **AuthRepository** - Secure credential storage operations

### Model Tests (`test/data/models/`)
Tests for data models:
- **DockerContainer** - JSON parsing and state properties
- **VmDomain** - JSON parsing and state checks
- **Share** - JSON parsing and usage calculations

### Utility Tests (`test/utils/`)
Tests for utility functions:
- **AppException** - Error handling and formatting
- **Formatters** - Byte formatting, uptime, temperature, state formatting

### Widget Tests (`test/widgets/`)
Tests for reusable UI widgets:
- **StatusBadge** - State-based badge rendering
- **KeyValueRow** - Label/value display
- **UsageBar** - Progress bar rendering with color selection

## Test Coverage

All tests use:
- **bloc_test** for cubit testing
- **mocktail** for mocking dependencies
- **flutter_test** for widget and unit testing

## Adding New Tests

When adding new features, ensure you add corresponding tests:
1. Cubit tests should mock repositories and verify state transitions
2. Repository tests should mock external dependencies (GraphQL client, secure storage)
3. Model tests should verify JSON parsing and computed properties
4. Widget tests should verify UI rendering and user interactions
