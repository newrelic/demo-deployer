# NewRelic configuration

The newrelic user configuration has the following schema:

```json
{
  "credentials": {

    "newrelic": {
      "licenseKey": "my_license_key",
      "nrPersonalApiKey": "my_personal_api_key",
      "nrAdminApiKey": "my_admin_api_key",
      "insightsInsertApiKey": "my_insigths_insert_api_key",
      "accountId": "my_account_id",
      "accountRootId": "my_account_root_id",
      "nrRegion": "US"
    }

  }
}
```

To set any of the value referenced above, follow the steps below. Note, some of those fields are optional.

### licenseKey

* Login to NewRelic
* On the NR1 view, expand the user name drop down on the top right corner, and click on `Account settings`
* Notice the `License Key` text and write down the associated value in your user config credentials for newrelic licenseKey

### nrPersonalApiKey

This key is typically used to invoke the newrelic REST APIs. More info can be found at https://docs.newrelic.com/docs/apis/get-started/intro-apis/types-new-relic-api-keys#personal-api-key

* Login to NewRelic
* On the NR1 view, expand the user name drop down on the top right corner, and click on `Account settings`
* On the left, click on `Users and roles`
* Find your user in the table, and click on that row
* Click on the `API Keys` column
* Click on the `New API Key` button
* Notice the entry starting with `NRAK-`. Write down this value in your user config credentials for newrelic nrPersonalApiKey

Please note the formatting for the <b>Personal API Key</b> has a prefix `NRAK-`.

### nrAdminApiKey

This key is typically used to invoke the newrelic REST APIs for creating or altering entities. 

* Login to NewRelic
* On the NR1 view, expand the user name drop down on the top right corner, and click on `Account settings`
* On the left, click on `API keys`
* Lower on the page, notice the table listing all users Admin API keys
* Find your user in the table, and click the `(Show Key)` link in the `Admin's API Key` column
* Write down the associated value in your user config credentials for newrelic nrAdminApiKey

Please note the formatting for the <b>Admin API Key</b> has a prefix `NRAA-`. If you do not see this prefix, regenerate a new admin key.

### insightsInsertApiKey

The insights insert api key is an optional element, mainly use for the handling of Logs in NewRelic.

* Login to NewRelic
* On the NR1 view, expand the user name drop down on the top right corner, and click on `Account settings`
* On the left, click on `API keys`
* On the right, see the `Other keys` section, click on the link `Insights API keys`
* See the `Insert Keys +`, and click on the `+` button to generate a new insights insert key
* Optional, add a note to indicate the usage for this key, for example `deployer`
* Notice the `Key` text and write down the associated value in your user config credentials for newrelic insightsInsertApiKey

### accountId

* Login to NewRelic
* On the NR1 view, expand the user name drop down on the top right corner, and click on `Account settings`
* In the URL, notice the integer after the `/accounts/` part, that integer is your accountId. Write it down in your user config credentials for newrelic accountId

### accountRootId

This accountRootId is optional. It's used for the handling of agent data coming from AWS Lambda.

* Login to NewRelic
* On the NR1 view, expand the user name drop down on the top right corner, and click on `Account settings`
* If your account is a sub-account, you should see a specific text `Sub-account information for [account name]`, with a smaller text below `This account belongs to [root account name]` and `[root accout name]` is a link. Click the `[root account name]` link
* Once on the root account, notice the integer after the `/accounts/` part, that integer is your accountRootId. Write it down in your user config credentials for newrelic accountRootId
* Alternatively, if you didn't see a link `[root account name]`, this means your account is the root account. Use the same integer value as the accountId for the accountRootId and write it down in your user config credentials for newrelic accountRootId.

### nrRegion

Typically the newrelic region is `US`. If you know your account is in a specific region, use that region value instead.
All possible regions are listed below:

* `US`
* `EU`
* `AP`
