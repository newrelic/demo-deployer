# New Relic Configuration

The `newrelic` user configuration has the following schema:

```json
{
  "credentials": {

    "newrelic": {
      "licenseKey": "my_license_key",
      "nrPersonalApiKey": "my_personal_api_key",
      "insightsInsertApiKey": "my_insigths_insert_api_key",
      "accountId": "my_account_id",
      "accountRootId": "my_account_root_id",
      "nrRegion": "US"
    }

  }
}
```

To set any of the value referenced above, follow the steps below.

> **Note:** Some fields are optional.

### licenseKey

The deployer requires your New Relic license key to make changes to your account. Read the [official New Relic documentation](https://docs.newrelic.com/docs/accounts/accounts-billing/account-setup/new-relic-license-key) to learn how to obtain your license key.

### nrPersonalApiKey

The deployer uses your Personal API key to make requests to New Relic's APIs on behalf of your account. Read the [official New Relic documentation](https://docs.newrelic.com/docs/apis/get-started/intro-apis/types-new-relic-api-keys#personal-api-key) to learn how to obtain a Personal API key.

### nrAdminApiKey (optional)

The deployer uses your Admin API key to make requests to certain New Relic APIs on behalf of your account. This is typically an **optional** element. Read the [official New Relic documentation](https://docs.newrelic.com/docs/apis/get-started/intro-apis/types-new-relic-api-keys#admin) to learn how to obtain an Admin API key.

### insightsInsertApiKey (optional)

The deployer uses your Insert API key to manage logs in New Relic. This is typically an **optional** element. Read the [official New Relic documentation](https://docs.newrelic.com/docs/apis/get-started/intro-apis/types-new-relic-api-keys#event-insert-key) to learn how to obtain an Insert API key.

### accountId

The deployer requires your New Relic account ID to make changes to your account. Read the [official New Relic documentation](https://docs.newrelic.com/docs/accounts/accounts-billing/account-setup/account-id) to learn how to obtain your account ID.

### accountRootId (optional)

The deployer uses your account's root ID for handling agent data coming from AWS Lambda. This is typically an **optional** element. To find your root Id:

1. Log in to New Relic
2. Expand the username drop down in the top right corner, and click on `Account settings`
3. If your account is a [sub-account](https://docs.newrelic.com/docs/accounts/install-new-relic/account-setup/manage-apps-or-users-sub-accounts), you should see specific copy "Sub-account information for [account name]" with smaller text below "This account belongs to [root account name]". Click "[root account name]". **If your account is not a sub-account, use the same value you used for `accountId`.**
4. Once you're on the root account, notice the integer after the `/accounts/` part of the URL. That integer is your `accountRootId`.

### nrRegion

Typically, your [New Relic region](https://docs.newrelic.com/docs/using-new-relic/welcome-new-relic/get-started/our-eu-us-region-data-centers) is `US`. If you know that your account is in a specific region, use that region value instead.

All possible regions are listed below:

* `US`
* `EU`
* `AP`
