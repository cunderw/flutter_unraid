# GraphQL Schema Sync

Detect drift between Unraid GraphQL API schema and local queries, models, and repositories.

## Usage

`/project:graphql-schema-sync <schema source: URL, file path, or pasted schema>`

## Workflow

### 1. Gather schema

Ask for one of:
- **Live server URL**: introspect the schema via GraphQL introspection query
- **Schema file**: read a `schema.graphql` file
- **Pasted schema**: accept relevant schema sections directly

### 2. Extract local expectations

Parse the codebase to build a map of what the app expects:

| Source | Extract |
|--------|---------|
| `lib/graphql/queries.dart` | All query strings — field names, types, nesting |
| `lib/graphql/mutations.dart` | All mutation strings — input types, response fields |
| `lib/data/models/*.dart` | `fromJson` field names and expected types |
| `lib/data/repositories/*.dart` | JSON path traversals |

### 3. Compare and detect drift

#### Breaking changes (Error)
- **Removed field**: field used in a query/model no longer exists
- **Type change**: field changed type (e.g., `String` → `Int`)
- **Removed type**: entire type used by the app was removed
- **Renamed field**: field renamed (heuristic: similar name + same parent type)

#### Nullable safety issues (Warning)
- **Nullable mismatch**: schema says nullable but `fromJson` uses non-null cast
- **Missing null handling**: schema field is nullable but model has `required` non-null field
- **List nullability**: schema returns nullable list but model assumes non-null

#### New API capabilities (Info)
- **New field available**: schema has fields the app doesn't query
- **New type available**: schema has types the app doesn't use
- **Deprecated field**: field used by the app is marked deprecated

### 4. Report

```
## GraphQL Schema Sync Report

### Breaking Changes
| Issue | Location | Details |

### Nullable Safety
| Issue | Location | Details |

### New API Capabilities
| Type | Field | Description |

### Suggested Fixes
1. ...
```

### 5. Auto-fix (when safe)

For nullable mismatches, generate fixes:
- Update `fromJson` to use nullable cast: `as String?`
- Update model field to be nullable: `final String?`
- Add fallback defaults: `?? ''` or `?? 0`

Always run `flutter analyze` and `flutter test` after any auto-fix.

$ARGUMENTS
