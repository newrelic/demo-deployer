# AWS configuration

The aws user configuration has the following schema:

```json
{
  "credentials": {

    "aws": {
      "apiKey": "my_api_key_value",
      "secretKey": "my_secret_key",
      "secretKeyPath": "my_secret_key_path",
      "region": "my_region"
    }

  }
}
```

To set each of the value referenced above, follow the steps below.

### apiKey and secretKey

* If you need a new AWS (free) account, follow the steps at the bottom of this page first.
* Login onto AWS console, with either your aws username/password, or through SSO (okta for example), https://aws.amazon.com/console/
* Under Services, go to IAM (manage access to AWS resources)
* Click the `Add user` button
* Enter a user name, this can be your username, for example `jsmith`
* Select `Programmatic access`. Do NOT select `AWS Management Console access` as this is not needed for the deployer.
* Click `Next`
* Select `Attach existing policies directly`
* Search and Select `AdministratorAccess`
* Click `Next: Tags`
* Add any key/value tag you may want (not needed by the deployer)
* Click `Next: Review`
* Click `Create User`
* Copy both the `Access key ID` which will be your apiKey value, and the `Secret access key` which will be your secretKey value.
* Put both values in your user config credentials for aws apiKey and secretKey

### secretKeyPath and region

In order to create and access EC2 resources, a .pem key file is required. Those .pem key file are bound to a specific AWS region.
To create a .pem key file, and use it with the deployer, follow the steps below:

* Login onto AWS console, with either your aws username/password, or through SSO (okta for example), https://aws.amazon.com/console/
* Under Services, go to EC2 (Virtual Servers in the Cloud)
* On the top right, select a specific region, for example `Oregon` which is `us-west-2`.
* In your browser URL, notice the `region` query string parameter. The value will be the region value to use in your user config credential for region.
* On the left, under `Network & Security`, select `Key Pairs`
* Click the `Create key pair` button
* Enter a name for your .pem key file. Typically, it's a good idea to user a region suffix, to remind you what region that file is associated to, although this is not required. You can name the file as you wish. For example `jsmithUsWest2`
* Select `pem` file format
* Optional, add any tag by clicking on the `Add new tag` button
* Click the `Create key pair` button. This will starts a file download on your browser. The file downloaded will be named for example `jsmithUsWest2.pem`.
* Move the downloaded file to a secure folder on your machine, for example under `$HOME/configs`
* IMPORTANT, in order for the .pem key file to be used, the file permissions need to be restricted to User read-only. You can do so with this command `sudo chmod 0400 *.pem`
* Get the absolute path of your .pem key file, this will be your user config credentials for secretKeyPath. For example `$HOME/configs/jsmithUsWest2.pem`
* For user config running with docker, the .pem key path needs to be the absolute path in the docker image that is running. The deployer is located in `/mnt/deployer` and the .pem key should be stored in `/mnt/deployer/configs`. So if you're planning to use docker with this user config, an example of secretKeyPath to use would be `/mnt/deployer/configs/jsmithUsWest2.pem`. For more information regarding running the deployer with docker look at [Running the deployer with Docker](../../../docker/run/README.md)

## Create a new AWS account

You can create a new AWS account, with some limited free access to some resources. To do so, follow the steps on https://aws.amazon.com 

