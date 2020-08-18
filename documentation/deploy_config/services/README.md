# Services

Any services needed for the deployment must be declared in the `services` list.
A `service` definition has the possible elements below. Some of those elements are optional.

```json
{
    "services":[
        {
            "id": "my_service_id",
            "display_name": "My Service",
            "local_source_path": "-b master git@source.datanerd.us:Demotron/V3-Pythontron.git",
            "source_repository": "-b master git@source.datanerd.us:Demotron/V3-Pythontron.git",
            "deploy_script_path": "deploy/linux/roles",
            "port": 5001,
            "destinations": ["resource_id_1"],
            "relationships": ["another_service_id"],
            "files":[
                {
                    "destination_filepath": "my_app_folder/example.json",
                    "content": { "key1": [1,2,3] }
                }
            ],
            "tags": {
              "my_tag1": "anything",
              "my_other_tag2": "else"
            }
        }
    ]
}
```

## id

This field is a user defined string and will be used as the identity for that service.
This value must be unique, contains alphanumeric character (any casing). Note, the '-' character is also allowed.
The maximum length for the value is 10 characters. This value is configured in the [`/src/config/app_config.yml`](/src/config/app_config.yml) for the element `serviceIdMaxLength`.

## display_name

This field is optional and may be used when the service is installed to display a user friendly name for that service. In the absence of this field, the value for the service_id will be used instead.

## local_source_path

This field is optional, and must be omitted if `source_repository` is specified. The value represent a local path when the source of the service to deploy can be found.

## source_repository

This field is optional, and must be omitted if `local_source_path` is specified. The value represent a GIT repository, which can either be an SSH string, or an HTTPS URI.
Note for the HTTPS usage, it is possible to use a GIT access token. For more information see [Git Credentials](../../user_config/credentials/git/README.md)

## deploy_script_path

This field is required. It represents a relative path from either the `local_source_path` or `source_repository` root where the ansible plays can be found for installing the services. A typical value is `/deploy/linux/roles` for the demo Trons applications.

## port

This field is required and represent an integer for the port to use for this service. Note, the port must be a number in the following range `[1024,65535]`.

## destinations

This field is required. It's an array of strings representing [resource identities](/documentation/deploy_config/resources/README.md). Those will be the resources to use for hosting the service.
The deployer will validate the dependent resources exist, and that no other service are configured to use the same port.

## relationships

This field is optional. It's an array of strings representing service identities.
This field is used when a service needs to have dependency injected at installation time from other services that are also deployed. The actual service URL will be handed over the installation process.

## files

This field is optional. It's an array of `file` element. Upon deployment, each of the file element get copied to the target service host in the specified location. This can be useful for creating required service configuration.

### file destination_filepath

If a file is specified, this field is required. It represents the relative path and filename for creating the file in the target host service directory.

### file content

If a file is specified, this field is required.
There are 2 possible usages for the content. It can either be a JSON content, or a single string representing a URL starting with `http`.

If the content is JSON, it is simply written out on the target filepath.

If the content is an `http` URL, the content is downloaded from that URL and saved on the target filepath. In this case, the content can be anything and does not have to be JSON.

Note, in either case, the service merge fields can be used to have an actual service property, dynamically replaced at deploy time. This can be leveraged to also inject dependent service URL in a service configuration file.

More information about merge fields can be found at [Merge fields](../merge_fields/README.md)

## tags

All services can have an optional `tags` element, which can contain a list of key/value pair. Those tags are additive to the potential `global_tags` defined at the root of the deploy config, and would eventually replace them in the context of that service (overriden for that service).
