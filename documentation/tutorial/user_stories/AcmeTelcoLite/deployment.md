## Deploying Telco Lite

In this step, you deploy the Telco Lite infrastructure in AWS and instrument its services with New Relic.

## Deploy your services

To begin, run `docker build` in the `demo-deployer` directory:

```console
$ cd demo-deployer
$ docker build -t deployer .
...
Successfully built bb4c573b380d
Successfully tagged deployer:latest
```

Now, you can run a docker container based on the image you've built and start the deployer:

```console
$ docker run -it\
    -v $HOME/configs/:/mnt/deployer/configs/\
    --entrypoint ruby deployer main.rb -c configs/<username>.docker.local.json -d documentation/tutorial/user_stories/AcmeTelcoLite/telcolite.aws.json
```

> **Note:** Don't forget to replace `<username>` with the same username you used when creating your credentials file.

This command spins up several services in AWS, so it can take over half an hour to run. When it finishes, you should see some output stating that the deployment was successful:

```console
[INFO] Executing Deployment
[✔] Parsing and validating Deployment configuration success
[✔] Provisioner success
[✔] Installing On-Host instrumentation success
[✔] Installing Services and instrumentations success
[INFO] Deployment successful!

Deployed Resources:

  simuhost (aws/ec2):
    ip: 34.201.60.23
    services: ["simulator"]

  uihost (aws/ec2):
    ip: 18.233.97.28
    services: ["webportal", "fluentd"]
    instrumentation:
       nr_infra: newrelic v1.12.1

  backendhost (aws/ec2):
    ip: 35.170.192.236
    services: ["promo", "login", "inventory", "plan", "fulfillment", "warehouse", "fluentd"]
    instrumentation:
       nr_infra: newrelic v1.12.1

  reportinghost (aws/ec2):
    ip: 54.152.82.127
    services: ["billing", "fluentd"]
    instrumentation:
       nr_infra: newrelic v1.12.1


Installed Services:

  simulator:
    url: http://34.201.60.23:5000

  webportal:
    url: http://18.233.97.28:5001
    instrumentation:
       nr_node_agent: newrelic v6.11.0
       nr_logging_in_context: newrelic

  promo:
    url: http://35.170.192.236:8001
    instrumentation:
       nr_python_agent: newrelic v5.14.1.144
       nr_logging_in_context: newrelic

  login:
    url: http://35.170.192.236:8002
    instrumentation:
       nr_python_agent: newrelic v5.14.1.144
       nr_logging_in_context: newrelic

  inventory:
    url: http://35.170.192.236:8003
    instrumentation:
       nr_python_agent: newrelic v5.14.1.144
       nr_logging_in_context: newrelic

  plan:
    url: http://35.170.192.236:8004
    instrumentation:
       nr_python_agent: newrelic v5.14.1.144
       nr_logging_in_context: newrelic

  fulfillment:
    url: http://35.170.192.236:8005
    instrumentation:
       nr_python_agent: newrelic v5.14.1.144
       nr_logging_in_context: newrelic

  billing:
    url: http://54.152.82.127:9001
    instrumentation:
       nr_java_agent: newrelic v5.14.0
       nr_logging_in_context: newrelic
       nr_logging: newrelic

  warehouse:
    url: http://35.170.192.236:9002
    instrumentation:
       nr_python_agent: newrelic v5.14.1.144
       nr_logging_in_context: newrelic

  fluentd:
    url: http://18.233.97.28:9999
    url: http://35.170.192.236:9999
    url: http://54.152.82.127:9999

Completed at 2020-08-11 11:27:00 -0700

[INFO] This deployment summary can also be found in:
[INFO]   /tmp/alec-telcolite/deploy_summary.txt
```

After configuring your environment, you only needed two commands (and a bit of patience) to spin up all the Telco Lite services!

## View your services

With your services running in AWS, log in to New Relic and select **APM** from the top navigation to see how your services are holding up:

![APM story introduction](imgs/story-introduction.png)

Yikes! The alerts, high response times, and red-colored indicators suggest things aren't well. Throughout [this story](story.md), you'll use New Relic to diagnose these issues, which are simultaneously affecting your services:

- [Issue 1: The Warehouse Portal has abnormally high response times](high-response-times.md)
- [Issue 2: Multiple services are raising error alerts](error-alerts.md)

> **Note:** If you don't see all the same alerts, don't worry. The simulated issues happen at regular intervals, so you should start seeing these problems in New Relic within 30 minutes to an hour.

## Tear down Telco Lite

When you're finished diagnosing all the issues effecting Telco Lite, you can tear down all the services you created in AWS. To remove the deployment and all associated cloud resources, execute the deployer with the same command as before, but add the parameter `-t` to specify a teardown execution:

```console
$ docker run -it\
    -v $HOME/configs/:/mnt/deployer/configs/\
    --entrypoint ruby deployer main.rb -c configs/<username>.docker.local.json -d documentation/tutorial/user_stories/AcmeTelcoLite/telcolite.aws.json -t
[INFO] Executing Teardown
[✔] Parsing and validating Teardown configuration success
[✔] Provisioner success
[✔] Uninstalling On-Host instrumentation success
[✔] Uninstalling Services and instrumentations success
[✔] Terminating infrastructure success
[INFO] Teardown successful!
```

> **Note:** Don't forget to replace `<username>` with the same username you used when creating your credentials file.

You're done! Congratulations, and we hope you learned a lot about using New Relic to investigate issues.