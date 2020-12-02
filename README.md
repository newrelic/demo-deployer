[![Experimental Project header](https://github.com/newrelic/opensource-website/raw/master/src/images/categories/Experimental.png)](https://opensource.newrelic.com/oss-category/#experimental)

# Demo Deployer

![Test](https://github.com/newrelic/demo-deployer/workflows/Test/badge.svg?event=push)

The deployer is a Ruby application that you can use to deploy and configure resources in various cloud environments.

The latest version of the demo-deployer is available from the GitHub Container Registry: `docker pull ghcr.io/newrelic/deployer:latest`

## Demo Catalog

While you can build components and deployment configurations for the deployer, we have created a set of demos so that you can hit the ground running with no prior work.

To learn how to use the deployer and run a demo, have a look at our [Demo catalog](https://github.com/newrelic/demo-catalog).

## Building the demo-deployer locally
First make sure to [Install Docker](https://docs.docker.com/get-docker/) and [install Git](https://git-scm.com/downloads) 

Clone the `demo-deployer` repository:

```console
$ git clone https://github.com/newrelic/demo-deployer.git
```

Then, navigate to the deployer directory and [build](https://docs.docker.com/engine/reference/commandline/build/) the container:

```console
$ cd demo-deployer
$ docker build -t deployer .
```

Follow our [Getting Started guide](https://github.com/newrelic/demo-catalog/blob/main/GETTING_STARTED.md) to deploy a demo scenario (note that you already have the deployer running locally if you have followed the above build steps)
## Developer

For more advanced insights of what the deployer is and does, check the [Developer documentation](documentation/developer/README.md). There, you'll learn about the deployer's architecture and how to run and test the application locally.

## Contributing

We encourage your contributions to improve the V3 Deployer! Keep in mind that when you submit your pull request, you'll need to sign the Contributor License Agreement (CLA) via the CLA-Assistant. You only have to sign the CLA one time per project.

If you have any questions, or to execute our corporate CLA, which required if your contribution is on behalf of a company,  please drop us an email at opensource@newrelic.com.

## License

V3 Deployer is licensed under the [Apache 2.0](http://apache.org/licenses/LICENSE-2.0.txt) License. V3 Deployer also uses source code from third-party libraries. You can find full details on which libraries are used and the terms under which they are licensed in the [third-party notices document](./THIRD_PARTY_NOTICES.md).
