# Secrets configuration

This field is used to store values that don't fit in with any particular set of credentials, but are still unique to a user. Any string based key/value pair can be added to the `secrets` section of the user config and accessed in the deployment configuration via [merge fields](../deploy_config/merge_fields/README.md). Ex: `[credential:secrets:database_password]` using the configuration below, would become `supersecurepassword`.
```json
{
  "secrets": {
      "database_password": "supersecurepassword"
  }
}
```


