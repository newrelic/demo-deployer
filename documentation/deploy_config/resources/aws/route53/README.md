# AWS Route53 resource type

You can use a `r53ip` type to define a Route53 Record Set of type A in an existing Route53 Hosted Zone.

## Pre-requisite

In order to use this type you'll need to create a hosted zone first, and have a registered domain associated with your hosted zone.
The deployer will validate the hosted zone exist.

## Configuration

There are 2 configuration options for `r53ip` resource, either by alias, or by ip and port.

### Configuration with alias

```json
{
    "resources":[
        {
            "id": "myservice",
            "provider": "aws",
            "type": "r53ip",
            "domain": "my.domain.com",
            "reference_id": "elb1"
        }
    ]
}
```

### Configuration with ip & port

```json
{
    "resources":[
        {
            "id": "myservice",
            "provider": "aws",
            "type": "r53ip",
            "domain": "my.domain.com",
            "listeners": ["service1"]
        }
    ]
}
```

## id

This field is a user defined string and will be used as the identity for that resource.
This value must be unique, contains alphanumeric character (any casing). Note, the '-' character is also allowed.
The maximum length for the value is 20 characters. This value is configured in the [`/src/app_config.yml`](/src/app_config.yml) for the element `resourceIdMaxLength`.

Once deployed, you can find that resource on AWS Console, Route53, Hosted Zone.
The naming convention for record set follows the format `[resource_id].[domain]`. In the example above, you'll find a record set of `myservice.my.domain.com`

## reference_id

This field is only used for creating an Alias record set.
The reference_id is the identity of an ELB resource.
The deployer will validate this dependent resource exist, and is of ELB type.

## listeners

This field is only used for creating a record set with a list of ip:port.
The listeners content is an array of service identities. However, only 1 service identity is expected.
The deployer will validate and throw specific errors if the service cannot be found, or if multiple services are provided.
