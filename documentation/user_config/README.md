# User config

The user config mainly contains credentials (api keys, license keys, secrets and tokens). Those are typically user, or account, specific and need to be handled with care. Those are also often re-used for multiple deployments of a same user.

We recommend placing this file in `$HOME/demo-deployer/configs` and naming it `$USER.credentials.local.json`. The deployer will automatically pick up the file if you follow these conventions.  If you have more than one '*.credentials.local.json' file in your configs directory the deployer will raise an error.  You will need to pass the '-c' flag with the path and name of the user config file you want to use or remove one of the user config files.

The structure of the user config is a list of credentials, for example:

```json
{
  "credentials": {

    "aws": {
      "apiKey": "my_aws_api_key",
      "secretKey": "my_aws_secret_key",
      "secretKeyPath": "/path/to/my/secretkey.pem",
      "region": "my_aws_region"
    },

    "azure": {
      "client_id": "my_client_id",
      "tenant": "my_tenant_id",
      "subscription_id": "my_subscription_id",
      "secret": "my_secret",
      "region": "my_region",
      "sshPublicKeyPath": "/path/to/my/id_rsa.pub"
    },

    "gcp": {
      "auth_kind": "serviceaccount",
      "service_account_email": "<sa_name>@<project_id>.iam.gserviceaccount.com",
      "service_account_file": "<path/to/service/account.json>",
      "project": "<project_id>",
      "scopes": ["https://www.googleapis.com/auth/compute"],
      "secretKeyPath": "/path/to/my/secretkey.pem",
      "region": "us-west1"
    },

    "newrelic": {
      "licenseKey": "my_new_relic_license_key",
      "insightsInsertApiKey": "my_new_relic_insights_api_key",
      "accountId": "my_new_relic_account_id"
    },

    "git": {
      "username": "my personal access token value"
    },

    "secrets": {
      "secret1": "<value of secret1>",
      "secret2": "<value of secret2>"
    }
  }
}
```

## Credentials

The references below give more details regarding how to setup specific vendors. Typically, tutorials use AWS and NewRelic.

* [Azure](azure.md)
* [Aws](aws.md)
* [Gcp](gcp.md)
* [NewRelic](newrelic.md)
* [GitHub](github.md)
* [Secrets](secrets.md)
