# Dependency Update

Check for outdated Flutter/Dart dependencies and validate safe upgrades.

## Usage

`/project:dependency-update`

## Workflow

### 1. Check for outdated packages

```bash
flutter pub outdated
```

Categorize by severity:

- **Patch** (e.g., `1.2.3` → `1.2.4`): Bug fixes, safe to upgrade
- **Minor** (e.g., `1.2.3` → `1.3.0`): New features, usually safe
- **Major** (e.g., `1.2.3` → `2.0.0`): Breaking changes, requires careful review

### 2. Attempt upgrades

For each outdated package (starting with patch-level):

1. Update the version constraint in `pubspec.yaml`
2. Run `flutter pub get`
3. Run `flutter analyze`
4. Run `flutter test`

If analyze or test fails, revert and flag as needing manual review.

### 3. Key packages to monitor

| Package | Purpose | Risk level |
|---------|---------|-----------|
| `flutter_bloc` / `bloc` | State management | Medium — API changes affect all cubits |
| `graphql` | GraphQL client | Medium — affects all repositories |
| `equatable` | Value equality | Low — stable API |
| `get_it` | Dependency injection | Low — stable API |
| `mocktail` | Test mocking | Low — test-only |
| `bloc_test` | Cubit testing | Low — test-only |

### 4. Safety rules

- Never auto-apply major version bumps without explicit user approval
- Always run full test suite before considering an upgrade safe
- If `flutter_bloc` or `graphql` have major updates, present migration notes
- Include relevant changelog entries in the report

### 5. Report

```
## Dependency Update Report

### Safe upgrades (validated)
| Package | From | To | Type | Analysis | Tests |

### Needs review
| Package | From | To | Type | Issue |

### Up to date
| Package | Version |
```

$ARGUMENTS
