# Resources

Any resources needed for the deployment must be declared in the `resources` list.
A `resource` schema has the following base schema:

```json
{
    "resources":[
        {
            "id": "my_resource_id",
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

Depending of which cloud provider is used, different resource types are available, and more element may be required for those specific types.
The list below is the list of all supported resource types. Follow the link for the resource types you're interested in deploying.

## AWS

* [EC2](aws/ec2/README.md)
* [Lambda](aws/lambda/README.md)
* [ELB](aws/elb/README.md)
* [Route53](aws/route53/README.md)

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
      "provider": "aws",
      "type": "ec2",
      "size": "t2.micro"
    }
  ]
}
```
