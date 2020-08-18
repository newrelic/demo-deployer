# NewRelic configuration

The newrelic user configuration has the following schema:

```json
{
  "credentials": {

    "newrelic": {
      "licenseKey": "my_license_key",
      "insightsInsertApiKey": "my_insigths_insert_api_key",
      "accountId": "my_account_id",
      "accountRootId": "my_account_root_id"
    }

  }
}
```

To set any of the value referenced above, follow the steps below. Note, some of those fields are optional.

### licenseKey

* Login to NewRelic
* On the NR1 view, expand the user name drop down on the top right corner, and click on `Account settings`
* Notice the `License Key` text and write down the associated value in your user config credentials for newrelic licenseKey

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
