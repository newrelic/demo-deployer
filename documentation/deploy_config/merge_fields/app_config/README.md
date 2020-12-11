# App Config merge fields

App config merge fields are applied to services. The syntax is `[app_config:category_name:property]`, where `category_name` is the type of category. New Relic is the only supported category.

## New Relic category

### api_url property
The URL of the New Relic API. Changes regions based on the `nrRegion` field in the user config, defaults to US if it is not provided.
Example: `[app_config:newrelic:api_url]`

### collector_url property
The URL of the New Relic collector API. Changes regions based on the `nrRegion` field in the user config, defaults to US if it is not provided.
Example: `[app_config:newrelic:collector_url]`

### infra_collector_url property
The URL of the New Relic infrastructure collector API. Changes regions based on the `nrRegion` field in the user config, defaults to US if it is not provided.
Example: `[app_config:newrelic:infra_collector_url]`

### infra_command_url property
The URL of the New Relic infrastructure command API. Changes regions based on the `nrRegion` field in the user config, defaults to US if it is not provided.
Example: `[app_config:newrelic:infra_command_url]`

### identity_url property
The URL of the New Relic identity API. Changes regions based on the `nrRegion` field in the user config, defaults to US if it is not provided.
Example: `[app_config:newrelic:identity_url]`

### logging_url property
The URL of the New Relic logging API. Changes regions based on the `nrRegion` field in the user config, defaults to US if it is not provided.
Example: `[app_config:newrelic:logging_url]`

### cloud_collector_url property
The URL of the New Relic cloud collector API. Changes regions based on the `nrRegion` field in the user config, defaults to US if it is not provided.
Example: `[app_config:newrelic:cloud_collector_url]`



