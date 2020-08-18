# Run the Deployer with docker

The deployer can be run through a built image. A [Dockerfile](../../../Dockerfile) is referenced at the root of the repository for building that image, and contain all the dependencies required to run the deployer.

## Pre-requesite

* Docker installed, see [Docker Install](../install/README.md) for installing
* A user config file stored locally on your machine, see [UserConfig](../../user_config/README.md) for creating your user config file. Copy this file into your `$HOME/configs` folder.
* A deploy config file stored locally on your machine, see [DeployConfig](../../deploy_config/README.md) for creating your deploy config. Copy this file into your `$HOME/configs` folder.

Note, several deploy config examples are available in [UserStories](https://source.datanerd.us/Demotron/V3-Documentation/tree/DEMO-2285-hello/UserStories)

## Building the docker image

* Open a shell command
* Navigate to your Deployer root directory
* Execute the command below to build the image locally
```bash
docker build -t deployer .
```

## Executing the deployer

After building the deployer docker image, you can now run the deployer through docker.
Any file dependency needed by the deployer needs to be explicitly handled through the use of volume. To make things simpler, we only mount your local `$HOME/configs` folder so all the files in that folder will be accessible by the docker image. The location for that `/configs` folder in the docker image will be `/mnt/deployer/configs`.
Important, you'll want to make sure the .pem key path in your user config file is using the docker image path. 

Therefore, the steps for running the deployer with docker are as follow:

* Open a shell command
* Navigate to your Deployer root directory
* Execute the command:
```bash
docker run -it\
    -v $HOME/configs/:/mnt/deployer/configs/\
    --entrypoint ruby deployer main.rb -c configs/[user config filename].json -d configs/[deploy config filename].json
```
**Note**: Be prepared to wait a while for the above command to finish. You will see output displaying the current operation.

### Example

I have a user config with some AWS credentials. 

The file is stored on my local machine in `/home/jerard/configs/jerard.docker.local.json`. The file looks like this:
```json
{
  "credentials": {
    "aws": {
      "apiKey": "my very secret api key",
      "secretKey": "my even more secret secret key",
      "secretKeyPath": "/mnt/deployer/configs/jerardUsEast2.pem",
      "region": "us-east-2"
    },

    "git": {
      "username": "a secret git personal access token"
    }
  }
}
```

I'm also having a deploy config file named `hello.local.json` stored on my local machine in `/home/jerard/configs/hello.local.json`. This file can be retrieved from the [Hello UserStory](https://source.datanerd.us/Demotron/V3-Documentation/tree/master/UserStories/Hello)

The file looks like this:
```json
{
  "services": [
    {
      "id": "app",
      "source_repository": "-b master https://[credential:git:username]@source.datanerd.us/Demotron/V3-Nodetron.git",
      "deploy_script_path": "deploy/linux/roles",
      "port": 5000,
      "destinations": ["host"]
    }
  ],

  "resources": [
    {
      "id": "host",
      "provider": "aws",
      "type": "ec2",
      "size": "t3.micro"
    }
  ],
}
```

My AWS .pem key file is also stored in `/home/jerard/configs/jerardUsEast2.pem` and I've validated the user permission is read-only for me only (`ls -l /home/jerard/configs` shows only `-r--------` ).

To run the deployer with those files I'll use this command:
```bash
docker run -it\
    -v /home/jerard/configs/:/mnt/deployer/configs/\
    --entrypoint ruby deployer main.rb -c configs/jerard.docker.local.json -d hello.local.json
```

## Tearing down resources

The deployer can also be run to remove all the resources provisioned. 

To do, the syntax is identical to the command used for deploying with the addition of a `-t` parameter to indicate a `teardown`.

### Example

To run a teardown for the previous deploy example (notice the `-t` at the end of the multiline command):

```bash
docker run -it\
    -v /home/jerard/configs/:/mnt/deployer/configs/\
    --entrypoint ruby deployer main.rb -c configs/jerard.docker.local.json -d hello.local.json -t
```

## Troubleshooting

### Docker error

While running docker, you may see the error below with a message "Cannot connect to the Docker daemon" and "Is the docker daemon running?".

```bash
docker run -it\
    -v /home/jerard/configs/:/mnt/deployer/configs/\
    --entrypoint ruby deployer main.rb -c configs/jerard.docker.local.json -d hello.local.json
docker: Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?.
See ‘docker run --help’.
```

This is typically happening when your docker application is not running (in the background). Find the Docker application on your machine, and start it. You should see the docker icon on your desktop indicating that docker is running. You can then run the docker command.

### Deployer Debug verbosity

Optionally, you may want to see a more detailed output of what the deployer is doing. You can add the following parameter to make the output more verbose `-l debug`
