# Instrumentations

This section is optional. A deploy config may not have any instrumentation defined. In this case no instrumentation will be deployed.

Instrumentions configuration has 2 main categories, sharing mostly identical fields. One category for `resources` and another category for `services`.

Here is an illustration of the configuration:

```json
{

  "instrumentations": {

    "resources": [
      {
        "id": "my_resource_instrumentation1",
        "resource_ids": ["host1","host2","host3"],
        "provider": "my_instrumentation_provider",
        "local_source_path": "/home/user/demo-newrelic-instrumentation",
        "source_repository": "-b main https://github.com/newrelic/demo-newrelic-instrumentation.git",
        "deploy_script_path": "deploy/linux/roles",
        "version": "1.4.11"
      }
    ],

    "services": [
      {
        "id": "my_service_instrumentation1",
        "service_ids": ["app1"],
        "provider": "my_instrumentation_provider",
        "provider_credential": "aws",
        "local_source_path": "/home/user/demo-newrelic-instrumentation",
        "source_repository": "-b main https://github.com/newrelic/demo-newrelic-instrumentation.git",
        "deploy_script_path": "deploy/python/linux/roles",
        "version": "5.4.1.134",
        "params":{
            "my_custom_key1": "anything",
            "any_other_key2": 123,
        }
      }
    ]
  }
}
```

## id

This field is a user defined string and will be used as the identity for that instrumation definition.
This value must be unique, contains alphanumeric character (any casing). Note, the '-' character is also allowed.
The maximum length for the value is 20 characters.

## resource_ids

This field is required for the `resources` category. It's an array of strings representing resource identities. Those will be the resources to target the installation of the instrumentation.
The deployer will validate the dependent resources exist.

## service_ids

This field is required for the `services` category. It's an array of strings representing service identities. Those will be the services to target the installation of the instrumentation.
The deployer will validate the dependent services exist.

## provider

This string represent the instrumentation provider to use. The value must match a credential definition within the user config file. An example of instrumentation provider will be `newrelic`. For more information regarding how to setup the `newrelic` user config credential, refer to this page [NewRelic UserConfig Credential](../../user_config/newrelic.md)

## provider_credential

Optional, this field represent an additional set of credential to be given to the instrumentor play. For example, a value of `aws` would look up all the credentials for the `aws` key in the [NewRelic UserConfig Credential](../../user_config/newrelic.md) file and add those credentials to each of the instrumentor plays.
This can be useful if an instrumentation play requires to have access to some cloud provider resources, for example, when using terraform and wanting to store the state file onto an S3 bucket.

## local_source_path

This field is optional, and must be omitted if `source_repository` is specified. The value represent a local path when the source of the instrumentation to deploy can be found.

## source_repository

This field is optional, and must be omitted if `local_source_path` is specified. The value represents a GitHub repository and can either be an SSH string or an HTTPS URI.

## version

This field is a string, and is optional. It represents a specific version of the instrumentation to install. The value is simply passed through to the instrumentation installer which will be using it to fetch the specific requested version.
Note, since the deployer has no knowledge of what the version refers to, there is no validation at the deployer level of that version. However, the instrumentation installer (ansible play) may validate this value and potentially throw a deploy time error if the version is not supported.

## params

This field is optional. It's a key/value pair list representing custom data to be passed through to the instrumentation installer (ansible play).

# Example of NewRelic instrumentation

This snippet is an example of instrumentation definitions for a set of resources and services.

```json
{
  "instrumentations": {
    "resources": [
      {
        "id": "nr_infra",
        "resource_ids": ["host1","host2","host3"],
        "provider": "newrelic",
        "source_repository": "-b main https://github.com/newrelic/demo-newrelic-instrumentation.git",
        "deploy_script_path": "deploy/linux/roles",
        "version": "1.4.11"
      },
      {
        "id": "nr_lambda",
        "resource_ids": ["lambda3"],
        "provider": "newrelic",
        "source_repository": "-b main https://github.com/newrelic/demo-newrelic-instrumentation.git",
        "deploy_script_path": "deploy/lambda_monitoring/roles",
        "version": "5.14.0.142"
      }
    ],
    "services": [
      {
        "id": "nr_python_agent",
        "service_ids": ["app1"],
        "provider": "newrelic",
        "source_repository": "-b main https://github.com/newrelic/demo-newrelic-instrumentation.git",
        "deploy_script_path": "deploy/python/linux/roles",
        "version": "5.4.1.134"
      },
      {
        "id": "nr_go_agent",
        "service_ids": ["app2"],
        "provider": "newrelic",
        "source_repository": "-b main https://github.com/newrelic/demo-newrelic-instrumentation.git",
        "deploy_script_path": "deploy/go/datanerd.us/demotron/V3-Gotron/roles",
        "version": "3.6.0"
      },
      {
        "id": "nr_lambda_python",
        "service_ids": ["app3"],
        "provider": "newrelic",
        "source_repository": "-b main https://github.com/newrelic/demo-newrelic-instrumentation.git",
        "deploy_script_path": "deploy/python/lambda/roles",
        "version": "5.14.0.142"
      },
      {
        "id": "nr_node_agent",
        "service_ids": ["app5"],
        "provider": "newrelic",
        "source_repository": "-b main https://github.com/newrelic/demo-newrelic-instrumentation.git",
        "deploy_script_path": "deploy/node/linux/roles",
        "version": "6.2.0"
      },
      {
        "id": "nr_logging",
        "service_ids": ["app1", "app2", "app5", "simulator"],
        "provider": "newrelic",
        "source_repository": "-b main https://github.com/newrelic/demo-newrelic-instrumentation.git",
        "deploy_script_path": "deploy/logging/roles"
      }
    ]

}
```
