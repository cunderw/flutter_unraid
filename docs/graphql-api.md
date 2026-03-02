# Unraid GraphQL API Reference

## Endpoint

```
http://10.1.0.254/graphql
```

Introspection is enabled — you can query `__type`, `__schema`, etc. to discover the exact schema.

## Useful introspection queries

### Get all fields of a type

```graphql
{
  __type(name: "Notification") {
    name
    fields {
      name
      type {
        name
        kind
        ofType {
          name
          kind
        }
      }
    }
  }
}
```

### Get input type fields

```graphql
{
  __type(name: "NotificationFilter") {
    name
    kind
    inputFields {
      name
      type {
        name
        kind
        ofType {
          name
          kind
        }
      }
    }
  }
}
```

### Get enum values

```graphql
{
  __type(name: "NotificationImportance") {
    name
    enumValues {
      name
    }
  }
}
```

### Get mutation fields

```graphql
{
  __type(name: "Mutation") {
    fields {
      name
      args {
        name
        type {
          name
          kind
          ofType {
            name
            kind
          }
        }
      }
      type {
        name
        kind
        ofType {
          name
          kind
        }
      }
    }
  }
}
```

## curl example

```bash
curl -s 'http://10.1.0.254/graphql' \
  -H 'Content-Type: application/json' \
  -d '{"query":"{ __type(name: \"Notification\") { name fields { name type { name kind ofType { name kind } } } } }"}'
```
