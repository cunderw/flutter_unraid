# Refactor

Perform safe, multi-file refactoring across all architecture layers.

## Usage

`/project:refactor <description of refactoring>`

## Safety protocol

1. **Before any refactoring**: Run `flutter test` to confirm all tests pass (baseline)
2. **Perform the refactoring** across all affected files
3. **After refactoring**: Run `flutter analyze` (zero issues) then `flutter test` (all pass)
4. **If tests fail**: fix the issue before reporting completion

## Supported operations

### 1. Rename feature

Rename across all layers — **every** reference must be updated:

- `lib/data/models/<old>.dart` → `<new>.dart`
- `lib/data/repositories/<old>_repository.dart` → `<new>_repository.dart`
- `lib/blocs/<old>/` → `lib/blocs/<new>/` (cubit + state)
- `lib/graphql/queries.dart` — rename query constant
- `lib/graphql/mutations.dart` — rename mutation constant
- `lib/di/injection.dart` — update registration
- `test/helpers/mocks.dart` — rename mock classes
- `test/helpers/factories.dart` — rename factory methods
- `test/helpers/test_data.dart` — rename JSON fixture builders
- All test files mirroring the renamed source files
- All widget files referencing the old names
- All `_tag` constants
- All import paths

Search for all references before renaming.

### 2. Extract screen-scoped cubit

Move a cubit from `lib/blocs/` to `lib/ui/screens/<screen>/cubit/`:

1. Verify no other screen depends on this cubit
2. Move cubit + state files
3. Update all imports in `lib/` and `test/`
4. Move corresponding test file

### 3. Promote to app-wide cubit

Move a screen-scoped cubit to `lib/blocs/<feature>/`:

1. Move cubit + state files
2. Update all imports
3. Move corresponding test file

### 4. Split model

Extract nested models into separate files:

1. Create new model file in `lib/data/models/`
2. Update parent model's `fromJson`
3. Add factory in `test/helpers/factories.dart`
4. Update JSON fixtures in `test/helpers/test_data.dart`

### 5. Merge cubits

Combine closely related cubits:

1. Merge state hierarchies (resolve naming conflicts)
2. Merge cubit methods (combine repos in constructor)
3. Update `BlocBuilder`/`BlocProvider` in widgets
4. Update DI if needed
5. Merge tests

### 6. Migrate state shape

Change data shape of a Loaded state:

1. Update state class definition
2. Update cubit emit calls
3. Update all `BlocBuilder` switch expressions in widgets
4. Update test expectations and `seed:` values
5. Update factory helpers

## Rules

- Never delete code without verifying it's unreferenced
- Always update `_tag` constants when renaming classes
- Always update mock/factory names when renaming
- Maintain test directory mirror of `lib/`
- Preserve `const` constructors and `Equatable` props

$ARGUMENTS
