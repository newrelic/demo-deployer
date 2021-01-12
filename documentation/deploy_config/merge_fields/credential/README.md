# Credential merge fields

Credential merge fields handle values from the user config file, applying them to services and global tags. These merge fields are only available if the corresponding value in the user config is populated. A credential merge field has the following syntax `[credential:credential_name:property]`, replace `credential_name` with the credential you would like to merge. New Relic is the only support credential.

## New Relic credential

### license_key property
Your New Relic license key. Example: `[credential:newrelic:license_key]`

### personal_api_key
Your New Relic personal API key. Example: `[credential:newrelic:personal_api_key]`

### admin_api_key property
Your New Relic admin API key. Example: `[credential:newrelic:admin_api_key]`

### insights_insert_api_key property
Your New Relic insights API key. Example: `[credential:newrelic:insights_insert_api_key]`

### account_id property
Your New Relic account ID. Example: `[credential:newrelic:account_id]`

### account_root_id property
Your New Relic root account ID, if you have one. Example: `[credential:newrelic:account_root_id]`

### region property
Your New Relic region. Example: `[credential:newrelic:region]`

## Secrets credential

See [Secrets Credential](../../../user_config/secrets.md)
