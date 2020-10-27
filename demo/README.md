# Demo

In this guide, you install and configure the prerequisites you need before you deploy resources with `demo-deployer` and learn how to set up your environment, spin up and tear down resources, and select the right demo for you.

> **Note:** The instructions below reference your `<username>` and a `$HOME` path. The user is your typical user name on your local machine. `$HOME` is where your user profile is stored on your machine. On MacOS, this is typically `/Users/<username>`. On Linux, `/home/<username>`. On Windows, `C:\Users\<username>`.

## Prerequisites

Before you learn how to use the deployer, you need to install the required dependencies, build your Docker image, and create your local user configuration file.

### Install Git

Ensure Git is installed on your machine:

```console
$ git version
git version 2.28.0
```

 If you don't see similar output, [download and install Git](https://git-scm.com/downloads).

 ### Install Docker and build the deployer image

 [Install Docker](https://docs.docker.com/get-docker/) and clone the `demo-deployer` repository:

```console
$ git clone https://github.com/newrelic/demo-deployer.git
```

Then, navigate to the deployer directory and [build](https://docs.docker.com/engine/reference/commandline/build/) the container:

```console
$ cd demo-deployer
$ docker build -t deployer .
```

### Create your configuration files

Create a directory in your home folder called `configs`:

```console
$ mkdir $HOME/configs
```

You'll store your configuration files in this folder and expose it to the docker process running the deployer.

Next, [create your local user config file](../documentation/user_config/README.md).

> **Important!** For AWS, you need a .pem key file. Name this file in the format `<username><region>.pem`. The `<region>` is the pascal-cased region you chose while setting up your .pem key. For example, `UsWest2` if you selected `us-west-2`. Store your .pem key file in `$HOME/configs/<username><region>.pem`.

Finally, store your local user config file at `$HOME/configs/<username>.docker.local.json`. You use that file when you run the deployer.

## Choose a demo

Alongside the user configuration file, the deployer uses a **deployment configuration file** to manage resources in your cloud environment. You can build a deployment configuration file yourself, but we also offer a catalog of configurations that you can use to get started.

Below are the demos we currently offer and what you can expect from them. If you'd like a guided walkthrough of a demo, we've also included developer guides for most of our demos:

| Demo | Description | Guide |
|---|---|---|
| [Hello World](https://raw.githubusercontent.com/newrelic/demo-deployer/main/demo/catalog/hello.aws.json) | A single-page web application with New Relic instrumentation | [Automate tagging of your entire stack
](https://developer.newrelic.com/automate-workflows/automated-tagging) |
| [Acme Telco Lite](https://raw.githubusercontent.com/newrelic/demo-deployer/main/demo/catalog/telcolite.aws.json) | A microservice architecture for an eCommerce platform, with simulated issues for investigating | [Use New Relic to diagnose problems in Acme Telco Lite](https://developer.newrelic.com/automate-workflows/diagnose-problems)

> **Important!** While the links provided in the **Demo** column are all for Amazon Web Services (AWS), the `demo-deployer` supports three prominent cloud providers: AWS, Microsoft Azure, and Google Cloud Platform (GCP). To use another provider, change the link from `<demo>.aws.json` to `<demo>.azure.json` or `<demo>.gcp.json`.

Copy the demo url for use in the next step.

## Deploy your services

Now that you've set up your local environment and chosen a demo, you can deploy your services:

```console
$ docker run -it\
    -v $HOME/configs/:/mnt/deployer/configs/\
    --entrypoint ruby deployer main.rb -c configs/<username>.docker.local.json -d <demo-url>
```

Don't forget to replace `<username>` and `<demo-url>` in this command. `<username>` is the same username you used when you created your credentials file. `<demo-url>` is the url or local path to your deployment configuration file.

> **Technical Detail:** Any file dependency needed by the deployer needs to be explicitly handled through the use of a mounted volume (using `-v`). To make things simpler, we only mount your local `$HOME/configs` directory so that all the files in that folder will be accessible by the docker image. The location for that `/configs` folder in the docker image will be `/mnt/deployer/configs`.
>
> If you're deploying to AWS, you'll want to make sure the .pem key path in your user config file is using the docker image path (`/mnt/deployer/configs/<filename>`).

This command spins up several services in the cloud provider of your choice, so it can take some time to run, depending on the demo. When it finishes, you should see some output stating that the deployment was successful:

```console
[INFO] Executing Deployment
[✔] Parsing and validating Deployment configuration success
[✔] Provisioner success
[✔] Installing On-Host instrumentation success
[✔] Installing Services and instrumentations success
[INFO] Deployment successful!

Deployed Resources:

...

Completed at 2020-08-11 11:27:00 -0700

[INFO] This deployment summary can also be found in:
[INFO]   /tmp/demo/deploy_summary.txt
```

## Tear down your resources

When you're finished with the demo, you can tear down all the services you created. To remove the deployment and all associated cloud resources, execute the deployer with the same command as before, but add the parameter `-t` to specify a teardown execution:

```console
$ docker run -it\
    -v $HOME/configs/:/mnt/deployer/configs/\
    --entrypoint ruby deployer main.rb -c configs/<username>.docker.local.json -d <demo-url> -t
[INFO] Executing Teardown
[✔] Parsing and validating Teardown configuration success
[✔] Provisioner success
[✔] Uninstalling On-Host instrumentation success
[✔] Uninstalling Services and instrumentations success
[✔] Terminating infrastructure success
[INFO] Teardown successful!
```

> **Note:** Don't forget to replace `<username>` and `<demo-url>` with the same values you used during deployment.

## Troubleshooting

You may see errors when running these docker commands, this section may help you diagnose these issues.

### Docker error

While running docker, you may see the error below:

```console
$ docker run -it\
    -v /home/jerard/configs/:/mnt/deployer/configs/\
    --entrypoint ruby deployer main.rb -c configs/<username>.docker.local.json -d <demo-url>
docker: Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?.
See ‘docker run --help’.
```

This typically happens when your docker application is not running (in the background). Find the Docker application on your machine, and start it. You should see the docker icon on your desktop indicating that docker is running. Then, you can try to deploy again.

### Deployer Debug verbosity

You may want to see a more detailed output of what the deployer is doing. You can add `-l debug` to make the output more verbose:

```console
$ docker run -it\
    -v /home/jerard/configs/:/mnt/deployer/configs/\
    --entrypoint ruby deployer main.rb -c configs/<username>.docker.local.json -d <demo-url> -l debug
```
