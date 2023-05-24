# Invalid Query behavior

The `INVALID-QUERY` behavior will run a select query against a table that does not exist, causing a `ER_NO_SUCH_TABLE` error. **Note**: The Tron must be configured to and connected to a database, otherwise this behavior will be ignored.

Note, leveraging the `PRE` and `POST` syntax should be use to indicate if the query should be run before, or after, the standard processing of the API.

## Value format

The value for this behavior has currently no use. You may pass anything (0 or empty strings are fine).

## Example

Query before the standard API execution for the tron having an id of `javatron1`
```bash
curl -i "http://localhost:8081/api/inventory/2" -H "x-demo-invalid-query-pre-javatron1: 0"
```

Query after the standard API execution for all trons
```bash
curl -i "http://localhost:8081/api/inventory/2" -H "x-demo-invalid-query-post: 0"
```

