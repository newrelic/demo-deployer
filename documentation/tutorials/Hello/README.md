# Hello

In this user story, you deploy a single application on a host and instrument both the host and the app with New Relic.

> **Note:** In the instructions below, there are references to `[user]` and a `$HOME` path.
>
> The user is your typical user name on your local machine. `$HOME` is where your user profile is stored on your machine. On MacOS this is typically `/Users/[user]`. On Linux, `/home [user]`. On Windows, `C:\Users\[user]`.

## Getting started

Before you begin, complete the [Getting Started](../README.md#getting-started) guide.

When you've finished, you'll have:

- Installed Docker
- Cloned the `demo-deployer`
- Created a user config file containing AWS (or Azure) and New Relic credentials
- Downloaded a .pem key file, if you're using AWS

## Deploying

In this story, you'll use the deployment configuration file: [hello.json](hello.json).

> **Note:** If you're using Azure instead of AWS, replace all instances of `hello.json` with `hello.azure.json`.

To execute the deployment with docker, run the below commands from within your local deployer directory:

```bash
docker run -it\
    -v $HOME/configs/:/mnt/deployer/configs/\
    --entrypoint ruby deployer main.rb -c configs/[user].docker.local.json -d documentation/tutorials/Hello/hello.json
```

> **Note:** Don't forget to replace `[user]` with the same username you used when creating your credentials file.

Because this command spins up infrastructure and instruments it with New Relic, it takes several minutes to run. When it finishes, you should see some output stating that the deployment was successful:

```console
[INFO] Executing Deployment
[✔] Parsing and validating Deployment configuration success
[✔] Provisioner success
[✔] Installing On-Host instrumentation success
[✔] Installing Services and instrumentations success
[INFO] Deployment successful!

Deployed Resources:

  host1 (aws/ec2):
    ip: 18.189.170.221
    services: ["app1"]
    instrumentation:
       nr_infra: newrelic v1.12.0

Installed Services:

  app1:
    url: http://18.189.170.221:5001
    instrumentation:
       nr_node_agent: newrelic v6.11.0

Completed at 2020-07-20 17:45:12 +0000

[INFO] This deployment summary can also be found in:
[INFO]   /tmp/jsmith-hello/deploy_summary.txt
```

Now, you can reach the app using the `app1` URL. (In this example, you'd visit `http://18.189.170.221:5001` in your browser.) You can also access the tron API like this, using `[app url]/api/inventory/3`.

Log in to NewRelic. You should see **Hello-App1** under **APM**, and a **Hello-Host1** in **Infrastructure**.

## Teardown

To remove the deployment, re-execute the deployer with the same command syntax and add the parameter `-t` to specify a teardown execution:

```bash
docker run -it\
    -v $HOME/configs/:/mnt/deployer/configs/\
    --entrypoint ruby deployer main.rb -c configs/[user].docker.local.json -d documentation/tutorials/Hello/hello.json -t
```

> **Note:** Don't forget to replace `[user]` with the same username you used when creating your credentials file.