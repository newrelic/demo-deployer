# GCP configuration

The gcp user configuration has the following schema:

```json
{
  "credentials": {

    "gcp": {
      "auth_kind": "serviceaccount",
      "service_account_email": "<sa_name>@<project_id>.iam.gserviceaccount.com",
      "service_account_file": "<path/to/service/account.json>",
      "project": "<project_id",
      "scopes": ["https://www.googleapis.com/auth/compute"],
      "secretKeyPath": "/path/to/my/secretkey.pem",
      "region": "us-west1"
    }

  }
}
```

To set each of the value referenced above, follow the steps below.

### service_account_email, service_account_file, project

* If you need a new GCP (free) account, follow the ['Create a new freetrial GCP account'](#Create-a-new-Gcp-account) steps at the bottom of this page first.
* Login onto GCP console, with either your username https://console.cloud.google.com/ 
* Near the top left, click on the drop down near `Google Cloud Platform` to create a new project.
* Fill a project name, and note down the project_id from the ID column. Set this value in your user config credential for the `project` field.
* Go to GCP IAM for Service Accounts at https://console.cloud.google.com/iam-admin/serviceaccounts
* Click `Create Service Account` at the top
* Fill an account name and description
* Click `Create`
* Select a role, for example `Owner` and click `Continue`
* Click `Done`
* On the service accounts page, find the entry in the list you've just created. It should mention `No keys`
* Notice the email address value, write down value and set this value in your user config credential for `service_account_email`
* On the right of that line click the symbol and `Create key` with the `JSON` format. This will download a json file on your machine
* Store this file on your machine, and write down the absolute path and set this value in your user config credential for `service_account_file`

### region

The region configuration is typically use for creating Virtual Machine hosts. You can pick a specific region by looking at the possible available choices on https://cloud.google.com/compute/docs/regions-zones .

* Chose a GCP region code for example `us-west1`
* Write down the region code in your user config credentials for gcp `region`

### secretKeyPath

In order to create and access GCP `Virtual Machines`, we need to create an SSH key pair. By default, those files are created in the ~/.ssh directory.

* Use this command to create an RSA SSH key pair with a length of 4096 bits `ssh-keygen -m PEM -t rsa -b 4096 -f $HOME/demo-deployer/configs/azrkey --N "" -C "compute-user"`. If you would like to create the key in a directory other than `HOME/demo-deployer/configs`, change the file path after the `-f` option. 
* Write down the relative path of the generated private key, which should be `configs/azrkey.pub` unless you provided your own file path. Place this path as the value of the `secretKeyPath` field.
* Upload the public key content to the GCP Compute metadata to allow this SSH key to be used with your project using https://console.cloud.google.com/compute/metadata
* Click `SSH Keys` tab
* Click `Edit`
* `Add item`
* Paste the content of you previously generated SSH public key file into the field
* Click `Save`

### scopes

This element defines the permissions associated with the GCP credentials. Currently, since the deployer only supports provisioning a `compute` instance, only the read-write scope for compute is defined with `https://www.googleapis.com/auth/compute`
Other values can be added to the array, more information is available at https://developers.google.com/identity/protocols/oauth2/scopes

## Create a new Gcp account

You can create a new Gcp account, with some limited free access to some resources. To do so, follow the steps on https://console.cloud.google.com/freetrial

