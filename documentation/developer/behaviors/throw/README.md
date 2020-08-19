# Throw behavior

The `THROW` behavior will throw an explicit exception. 

Note, leveraging the `PRE` and `POST` syntax should be use to indicate if the error should be thrown before, or after, the standard processing of the API.

## Value format

The value for this behavior has currently no use. You may pass anything (0 or empty strings are fine).

## Example

Throw an exception before the standard API execution for the tron having an id of `javatron1`
```bash
curl -i "http://localhost:8081/api/inventory/2" -H "x-demo-throw-pre-javatron1: 0"
```

Throw an exception after the standard API execution for all trons
```bash
curl -i "http://localhost:8081/api/inventory/2" -H "x-demo-throw-post: 0"
```

