# Azure configuration

The azure user configuration has the following schema:

```json
{
  "credentials": {

    "azure": {
      "client_id": "my_client_id",
      "tenant": "my_tenant_id",
      "subscription_id": "my_subscription_id",
      "secret": "my_secret",
      "region": "my_region",
      "sshPublicKeyPath": "my_ssh_public_key_path"
    }

  }
}
```

To set each of the value referenced above, follow the steps below.

### tenant, client_id and secret

* If you need a new Azure (free) account, follow the ['Create a new Azure account'](#Create-a-new-Azure-account) steps at the bottom of this page first.
* Login onto Azure portal, with either your username https://portal.azure.com/#home.
_Note, if you're a NewRelic employee your username should be in the form of [username]@datanerd.us then when prompted with Okta SSO, enter your usual newrelic credentials and confirm the push notification on your mobile device._
* On the left, select `Azure Active Directory`
* Write down the `Tenant ID` value displayed in the `Tenant information`, this will be your user config credentials for azure tenant
* Select `App registrations`
* Click `New registration`
* Enter a user-facing display name, this can be anything, for example `deployer`, leave all default options
* Click `Register`
* Write down the `Application (client) ID` value, this will be your user config credentials for azure client_id
* Select `Certificates & Secrets`
* Click `New client secret`
* Add a description, for example `Secret for accessing the portal`
* Optional, change the secret expiration
* Click `Add`
* Write down the `Value`, this will be your user config credentials for azure secret

### subscription_id

* If you need a new Azure (free) account, follow the ['Create a new Azure account'](#Create-a-new-Azure-account) steps at the bottom of this page first.
* Login onto Azure portal, with either your username https://portal.azure.com/#home.
_Note, if you're a NewRelic employee your username should be in the form of [username]@datanerd.us then when prompted with Okta SSO, enter your usual newrelic credentials and confirm the push notification on your mobile device._
* On the left, click the `Home` icon
* Clich the `Subscriptions` tile
* If you don't have any subscription, create a new one by clicking the `+ Add` button.
_Note, if you're a NewRelic employee, there should already be a subscription. If not, follow up with the ask-it channel._
* Write down the `Subscription ID` value displayed in the subscriptions list, this will be your user config credentials for azure tenant
* Select `Access control (IAM)` on the left.
* Click the `Add` button and select `Add role assignment`
* Select `Owner` as the role, `User, group or service principal` as what you assigning access to, and select the app you registered earlier.
* Save the role assignment.

### region

The region configuration is typically use for creating Virtual Machine hosts. You can pick a specific region by looking at the possible available choices on https://azure.microsoft.com/en-us/global-infrastructure/geographies/ .
Unfortunately, the region code to use are not listed, but can infered from Azure source code at https://github.com/Azure/azure-libraries-for-net/blob/master/src/ResourceManagement/ResourceManager/Region.cs

* Chose an azure region code for example `westus2`
* Write down the region code in your user config credentials for azure region

### sshPublicKeyPath

In order to create and access azure `Virtual Machines`, we need to create an SSH key pair.

* Use this command to create an RSA SSH key pair with a length of 4096 bits in the `$HOME/demo-deployer/configs` directory: `ssh-keygen -m PEM -t rsa -b 4096 -f $HOME/demo-deployer/configs/azrkey`. If you would like to place the files in a different directory, just change the file path after the `-f` option.
* Enter the relative path to the file you just created as the sshPublicKeyPath. This should be `configs/azrkey.pub`. If you created the file in a different directory, then you should use that path instead.

## Create a new Azure account

You can create a new Azure account, with some limited free access to some resources. To do so, follow the steps on https://azure.microsoft.com/en-us/free
