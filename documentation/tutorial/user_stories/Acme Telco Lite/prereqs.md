# Getting started

Before you begin this tutorial, complete [Step 0](../../README.md#step-0---install-pre-reqs--create-configs).

When you've finished, you'll have:

- Installed Docker
- Cloned the demo-deployer
- Created a user config file containing AWS and New Relic credentials
- Downloaded a .pem key file from AWS

> **Note:** While the demo-deployer supports user credentials from AWS, Azure, or GCP, the Acme Telco Lite stories require that you use AWS credentials.

Your user config file must contain the following keys:

```json
{
    "credentials": {
        "aws": {
            "apiKey": "your_api_key",
            "secretKey": "your_secret_key",
            "secretKeyPath": "configs/your_key_file_name.pem",
            "region": "your_region"
        },
        "newrelic": {
            "licenseKey": "your_license_key",
            "insightsInsertApiKey": "your_insights_insert_api_key",
            "nrPersonalApiKey": "your_personal_api_key",
            "accountId": "your_account_id"
        },
    }
}
```

Great! Now, you're all set up and ready to [deploy Acme Telco Lite](deployment.md).