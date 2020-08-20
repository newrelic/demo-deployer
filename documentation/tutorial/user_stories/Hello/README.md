# User Story: Hello

This user story is a single app deployment on a host, with NewRelic instrumentation for the host and the application. 

Note, in the instructions below, there are references to `[user]` and a `$HOME` path.
The user is your typical user name on your local machine. 
`$HOME` similarly is where your user profile is stored on your machine. On MacOS this is typically `/Users/[user]`, on Linux `/home/[user]` and windows `C:\Users\[user]`

## Pre-requesite

* The tutorial Step-0 is completed

## Deploying

The deploy config file [hello.json](hello.json) is provided for this user story. Make a copy of this file and put it in your configs folder at `$HOME/configs`.

To execute the deployment with docker, run the below commands from within your local deployer directory:

* Build the docker image with:
```bash 
docker build -t deployer .
``` 
* Execute the deployer with the syntax below. This command will take several minutes.
```bash
docker run -it\
    -v $HOME/configs/:/mnt/deployer/configs/\
    --entrypoint ruby deployer main.rb -c configs/[user].docker.local.json -d configs/hello.json
```

### Example output from the Demo Deployer

Assuming the following:
* my `[user]` name is `jsmith`
* I've created an AWS .pem key file stored at `$HOME/configs/jsmithUsWest2.pem`
* The AWS credentials secret key path is set in my user config file to `/mnt/deployer/configs/jsmithUsWest2.pem`

Execute the command below to run the deployer with the `hello.json` deploy config file:
```bash
> docker run -it\
    -v $HOME/configs/:/mnt/deployer/configs/\
    --entrypoint ruby deployer main.rb -c configs/jsmith.docker.local.json -d configs/hello.json
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

>
```
Once deployed, you can reach the app using the app1 URL, for example in a browser http://18.189.170.221:5001

You can also access the tron API like this http://18.189.170.221:5001/api/inventory/3

After login to NewRelic, you should see an "App1" under APM, and a "host1" in infrastructure

## Teardown

To remove the deployment, re-execute the deployer with the same command syntax and add the parameter `-t` to specify a teardown execution.

For example:
```bash
> docker run -it\
    -v $HOME/configs/:/mnt/deployer/configs/\
    --entrypoint ruby deployer main.rb -c configs/jsmith.docker.local.json -d configs/hello.json -t
...
```
