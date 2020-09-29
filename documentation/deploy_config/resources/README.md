# Resources

Any resources needed for the deployment must be declared in the `resources` list.
A `resource` schema has the following base schema:

```json
{
    "resources":[
        {
            "id": "my_resource_id",
            "display_name": "DisplayName",
            "provider": "cloud_provider",
            "type": "my_resource_type",
            "tags": {
              "my_tag1": "anything",
              "my_other_tag2": "else"
            }
        }
    ]
}
```

## id

This field is a user defined string and will be used as the identity for that resource.
This value must be unique, contains alphanumeric character (any casing). Note, the '-' character is also allowed.
The maximum length for the value is 20 characters. This value is configured in the [`/src/config/app_config.yml`](/src/config/app_config.yml) for the element `resourceIdMaxLength`.

## display_name

This field is optional and may be used when the resource is installed to display a user friendly name for that resource. In the absence of this field, the value for the resource_id will be used instead.

## cloud provider specifics

Depending of which cloud provider is used, different resource types are available, and more element may be required for those specific types.
The list below is the list of all supported resource types. Follow the link for the resource types you're interested in deploying.

## AWS

* [EC2](aws/ec2/README.md)
* [Lambda](aws/lambda/README.md)
* [ELB](aws/elb/README.md)
* [Route53](aws/route53/README.md)
* [S3](aws/s3/README.md)

## Azure

* [VM](azure/vm/README.md)

## tags

All resources can have an optional `tags` element, which can contain a list of key/value pair. Those tags are additive to the potential `global_tags` defined at the root of the deploy config, and would eventually replace them in the context of that resource (overriden for that resource).

### Example

Here is an example of resources definition for a deploy config.

```json
{
  "resources": [
    {
      "id": "host1",
      "display_name": "MyHost1",
      "provider": "aws",
      "type": "ec2",
      "size": "t2.micro"
    }
  ]
}
```
