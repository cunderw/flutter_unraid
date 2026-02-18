# Test Coverage Report — Flutter Unraid

## Summary

Comprehensive test coverage has been added to the Flutter Unraid project. This report outlines the current test structure, newly added tests, and coverage improvements.

## Test Structure

Tests mirror the `lib/` directory structure:

```
test/
├── widget_test.dart                # App smoke test
├── blocs/                          # Cubit tests (6 files)
│   ├── auth/
│   ├── docker/
│   ├── shares/
│   ├── system/
│   ├── vms/
│   └── container_logs/
├── data/
│   ├── models/                     # Model tests (5 files) ✨ NEW
│   │   ├── array_data_test.dart
│   │   ├── docker_container_test.dart
│   │   ├── share_test.dart
│   │   ├── system_info_test.dart
│   │   └── vm_domain_test.dart
│   └── repositories/               # Repository tests (5 files) ✨ 4 NEW
│       ├── auth_repository_test.dart
│       ├── docker_repository_test.dart
│       ├── share_repository_test.dart
│       ├── system_repository_test.dart
│       └── vm_repository_test.dart
├── ui/
│   ├── screens/                     # Screen tests (12 files) ✨ NEW
│   │   ├── login_screen_test.dart
│   │   ├── home/
│   │   │   ├── home_screen_test.dart
│   │   │   └── tabs/
│   │   │       ├── main_tab_test.dart
│   │   │       ├── docker_tab_test.dart
│   │   │       ├── vms_tab_test.dart
│   │   │       └── shares_tab_test.dart
│   │   └── container_detail/
│   │       ├── container_detail_screen_test.dart
│   │       ├── container_status_section_test.dart
│   │       ├── container_actions_section_test.dart
│   │       ├── container_config_section_test.dart
│   │       ├── container_ports_section_test.dart
│   │       └── container_logs_section_test.dart
│   └── widgets/                     # Widget tests (13 files) ✨ NEW
│       ├── cards/
│       │   ├── action_card_test.dart
│       │   ├── info_card_test.dart
│       │   └── stat_card_test.dart
│       ├── data_display/
│       │   ├── status_badge_test.dart
│       │   ├── key_value_row_test.dart
│       │   └── usage_bar_test.dart
│       ├── feedback/
│       │   ├── loading_indicator_test.dart
│       │   ├── empty_state_test.dart
│       │   ├── error_display_test.dart
│       │   ├── inline_error_test.dart
│       │   └── confirmation_dialog_test.dart
│       ├── inputs/
│       │   └── app_text_field_test.dart
│       └── layout/
│           └── section_header_test.dart
└── helpers/                         # Test utilities
    ├── factories.dart
    ├── get_it_helpers.dart
    ├── mocks.dart
    ├── pump_helpers.dart
    └── test_data.dart
```

## Tests Added

### Model Tests (5 new files)

All models now have comprehensive tests covering:
- JSON parsing (`fromJson`)
- Default value handling
- Computed getters
- Edge cases

| Model | Test File | Tests |
|-------|-----------|-------|
| `docker_container.dart` | `docker_container_test.dart` | ✅ ContainerPort parsing, displayString, DockerContainer parsing, displayName, state getters |
| `share.dart` | `share_test.dart` | ✅ Parsing, displayName, usagePercent edge cases |
| `vm_domain.dart` | `vm_domain_test.dart` | ✅ Parsing, displayName, state getters (running, paused, stopped, crashed) |
| `system_info.dart` | `system_info_test.dart` | ✅ OsInfo, CpuInfo, MemoryUtilization, SystemInfo parsing |
| `array_data.dart` | `array_data_test.dart` | ✅ Capacity, ArrayCapacity, ArrayDisk, ArrayData parsing, isHealthy, usagePercent, isStarted, totalDisks |

### Repository Tests (4 new files)

All repositories now have comprehensive tests covering:
- Query/mutation success paths
- Error handling
- Variable passing
- Edge cases

| Repository | Test File | Tests |
|------------|-----------|-------|
| `docker_repository.dart` | `docker_repository_test.dart` | ✅ getContainers, startContainer, stopContainer, restartContainer, removeContainer, getContainerLogs |
| `system_repository.dart` | `system_repository_test.dart` | ✅ getSystemInfo, getArrayData, setArrayState |
| `share_repository.dart` | `share_repository_test.dart` | ✅ getShares |
| `vm_repository.dart` | `vm_repository_test.dart` | ✅ getVms, startVm, stopVm, forceStopVm, pauseVm, resumeVm, rebootVm |

### Widget Tests (13 new files)

Comprehensive widget tests covering all reusable UI components:

**Cards:**
| Widget | Test File | Tests |
|--------|-----------|-------|
| `action_card.dart` | `action_card_test.dart` | ✅ Child display, title, leading widget, actions, tappability, Card rendering |
| `info_card.dart` | `info_card_test.dart` | ✅ Child display, title, leading/trailing widgets, custom padding, tappability |
| `stat_card.dart` | `stat_card_test.dart` | ✅ Label/value display, icon, trailing widget, Card rendering |

**Data Display:**
| Widget | Test File | Tests |
|--------|-----------|-------|
| `status_badge.dart` | `status_badge_test.dart` | ✅ Label display, factory methods (forContainerState, forVmState, forArrayState), color indicators |
| `key_value_row.dart` | `key_value_row_test.dart` | ✅ Label/value display, valueWidget, fixed width, ellipsis overflow |
| `usage_bar.dart` | `usage_bar_test.dart` | ✅ Progress bar, label/detail, percentage clamping, custom height |

**Feedback:**
| Widget | Test File | Tests |
|--------|-----------|-------|
| `loading_indicator.dart` | `loading_indicator_test.dart` | ✅ Displays spinner, optional message, centering |
| `empty_state.dart` | `empty_state_test.dart` | ✅ Message display, custom icons, optional actions, centering |
| `error_display.dart` | `error_display_test.dart` | ✅ Error message, icon, retry button, centering, text alignment |
| `inline_error.dart` | `inline_error_test.dart` | ✅ Error message, icon, retry button with tooltip, full width |
| `confirmation_dialog.dart` | `confirmation_dialog_test.dart` | ✅ Title/message display, custom labels, return values, AlertDialog |

**Inputs:**
| Widget | Test File | Tests |
|--------|-----------|-------|
| `app_text_field.dart` | `app_text_field_test.dart` | ✅ Label/hint, prefix/suffix icons, obscureText, validation, callbacks |

**Layout:**
| Widget | Test File | Tests |
|--------|-----------|-------|
| `section_header.dart` | `section_header_test.dart` | ✅ Title uppercase, trailing widget, custom padding, Row layout |

### Screen Tests (12 new files)

Comprehensive screen tests covering all major screens and tabs:

| Screen | Test File | Tests |
|--------|-----------|-------|
| `login_screen.dart` | `login_screen_test.dart` | ✅ Form display, validation hints, error states, loading states, visibility toggle |
| `home_screen.dart` | `home_screen_test.dart` | ✅ App bar, navigation bar, tabs, menu options |
| `main_tab.dart` | `main_tab_test.dart` | ✅ Loading/error/loaded states, system info display, stat cards, array status |
| `docker_tab.dart` | `docker_tab_test.dart` | ✅ Loading/error/empty states, container list, status badges, action buttons |
| `vms_tab.dart` | `vms_tab_test.dart` | ✅ Loading/error/empty states, VM list, status badges, icons |
| `shares_tab.dart` | `shares_tab_test.dart` | ✅ Loading/error/empty states, share list, icons |
| `container_detail_screen.dart` | `container_detail_screen_test.dart` | ✅ Container not found, app bar title, all sections display, ports conditional display |
| `container_status_section.dart` | `container_status_section_test.dart` | ✅ Container icon, name, status text, status badge |
| `container_actions_section.dart` | `container_actions_section_test.dart` | ✅ Actions title, start/stop/restart buttons based on state |
| `container_config_section.dart` | `container_config_section_test.dart` | ✅ Configuration title, image info, container ID, auto start |
| `container_ports_section.dart` | `container_ports_section_test.dart` | ✅ Ports title, port mappings, IP display, multiple ports |
| `container_logs_section.dart` | `container_logs_section_test.dart` | ✅ Logs title, loading state, error display, log lines, expand/collapse |

### Cubit Test Improvements

Enhanced existing cubit tests with missing ActionError coverage:

| Cubit | Improvement |
|-------|-------------|
| `docker_cubit_test.dart` | ✅ Added ActionError tests for `stopContainer` and `restartContainer` |

## Test Coverage by Category

### ✅ Fully Tested

- **Models**: 5/5 (100%)
  - docker_container ✅
  - share ✅
  - vm_domain ✅
  - system_info ✅
  - array_data ✅

- **Repositories**: 5/5 (100%)
  - auth_repository ✅
  - docker_repository ✅
  - system_repository ✅
  - share_repository ✅
  - vm_repository ✅

- **Cubits**: 6/6 (100%)
  - auth_cubit ✅
  - docker_cubit ✅
  - system_cubit ✅
  - shares_cubit ✅
  - vm_cubit ✅
  - container_logs_cubit ✅

### Cubit Test Completeness

All cubit tests follow the standard pattern:

✅ **Initial state assertion**  
✅ **Load success path**: `[Loading, Loaded]`  
✅ **Load failure path**: `[Loading, Error]`  
✅ **Mutation success paths**  
✅ **Mutation ActionError paths** (with `seed:` for pre-loaded state)  
✅ **Loaded state computed getter tests**

Example from `docker_cubit_test.dart`:
- ✅ `load()` - success and failure paths
- ✅ `startContainer()` - success and ActionError paths
- ✅ `stopContainer()` - success and ActionError paths
- ✅ `restartContainer()` - success and ActionError paths
- ✅ `removeContainer()` - success and error paths
- ✅ Computed getters: `running`, `stopped` counts

## Test Patterns

### Model Tests

```dart
group('fromJson', () {
  test('parses valid JSON correctly', () { /* ... */ });
  test('handles missing optional fields', () { /* ... */ });
});

group('computed getters', () {
  test('calculates correctly', () { /* ... */ });
  test('handles edge cases', () { /* ... */ });
});
```

### Repository Tests

```dart
group('getItems', () {
  test('returns list on success', () async {
    when(() => mockClient.query(any())).thenAnswer(
      (_) async => makeQueryResult(makeItemsResponseJson()),
    );
    final result = await repo.getItems();
    expect(result.length, greaterThan(0));
  });

  test('throws exception when query fails', () async {
    when(() => mockClient.query(any())).thenAnswer(
      (_) async => makeErrorQueryResult(OperationException(...)),
    );
    expect(() => repo.getItems(), throwsA(isA<OperationException>()));
  });
});
```

### Cubit Tests

```dart
group('performAction', () {
  blocTest<Cubit, State>(
    'success path',
    build: () { /* setup */ },
    act: (cubit) => cubit.performAction(),
    expect: () => [Loading(), Loaded()],
  );

  blocTest<Cubit, State>(
    'ActionError when fails and state is Loaded',
    seed: () => Loaded([data]),
    build: () { /* setup failure */ },
    act: (cubit) => cubit.performAction(),
    expect: () => [isA<ActionError>()],
  );
});
```

## Test Utilities

The project uses a comprehensive set of test helpers:

### `test/helpers/mocks.dart`
- Mock classes for all services, repositories, and cubits
- Uses `mocktail` package

### `test/helpers/factories.dart`
- Factory methods: `make<Model>()` with named params
- Shortcut factories: `makeRunningContainer()`, `makeStoppedVm()`, etc.

### `test/helpers/test_data.dart`
- JSON response builders: `make<Type>ResponseJson()`
- GraphQL response wrappers: `makeQueryResult()`, `makeErrorQueryResult()`

### `test/helpers/pump_helpers.dart`
- Widget test helpers: `pumpApp()`, `pumpAppWithBlocs()`

### `test/helpers/get_it_helpers.dart`
- GetIt reset utilities for widget tests

## Running Tests

```bash
# Install dependencies
flutter pub get

# Run all tests
flutter test

# Run specific test file
flutter test test/data/models/docker_container_test.dart

# Run tests by directory
flutter test test/data/models/
flutter test test/data/repositories/
flutter test test/blocs/
flutter test test/ui/screens/
flutter test test/ui/widgets/

# Run tests with coverage
flutter test --coverage

# Run analysis
flutter analyze
```

## Coverage Metrics

With the newly added tests, the project now has comprehensive coverage of:
- ✅ All 5 data models (100%)
- ✅ All 5 repositories (100%)
- ✅ All 6 cubits with proper error handling paths (100%)
- ✅ All 12 screens/sections (100%)
- ✅ All 13 reusable widgets (93% - error_snackbar is a helper function)
- ✅ Critical business logic paths
- ✅ Error scenarios and edge cases

### Test File Count

| Category | Before | After | Added |
|----------|--------|-------|-------|
| Model tests | 0 | 5 | +5 |
| Repository tests | 1 | 5 | +4 |
| Cubit tests | 6 | 6 | Enhanced |
| Screen tests | 0 | 12 | +12 |
| Widget tests | 1 | 14 | +13 |
| **Total** | **8** | **42** | **+34** |

### UI Test Coverage

| Category | Tested | Total | Coverage |
|----------|--------|-------|----------|
| Screens | 12 | 12 | 100% |
| Widgets | 13 | 14 | 93% |

**Note**: All screen files and nearly all widget files now have comprehensive test coverage. The only untested file is `error_snackbar.dart` which is a helper function rather than a traditional widget component.

## Key Achievements

1. **Complete model coverage**: All 5 models have comprehensive tests
2. **Complete repository coverage**: All 5 repositories have comprehensive tests
3. **Enhanced cubit tests**: Added missing ActionError test cases
4. **Complete screen coverage**: Tests for all 12 screens/sections (100%)
5. **Complete widget coverage**: Tests for 13 of 14 widgets (93%)
6. **Enhanced test helpers**: Updated pump_helpers and get_it_helpers for easier testing
7. **Consistent patterns**: All tests follow project conventions
8. **Comprehensive helpers**: Full suite of mocks, factories, and test data

## Next Steps

The test infrastructure is complete and ready for:
1. ✅ Adding tests for new features (models, repositories, cubits, screens, widgets)
2. ✅ UI/Widget tests for all components (complete)
3. 🔄 Integration tests for end-to-end flows (optional)
4. ✅ Running tests in CI/CD pipeline

## Notes

- All tests use `mocktail` for mocking (not mockito)
- All tests use `bloc_test` for cubit testing
- Test directory structure mirrors `lib/` directory
- All new tests follow existing patterns from `auth_repository_test.dart` and cubit tests
- Test helpers are located in `test/helpers/` for reuse

---

**Generated**: 2026-02-18  
**Comprehensive test coverage established for Flutter Unraid project** ✅
