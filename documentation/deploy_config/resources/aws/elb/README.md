# AWS ELB resource type

You can use a `elb` type to define a load balancer resource.This is an AWS ELB, specifically an application load balancer.
The below json illustrate the structure of this resource definition.

```json
{
    "resources": [
        {
            "id": "appelb1",
            "provider": "aws",
            "type": "elb",
            "listeners": ["..."],
        }
    ]
}
```

### id

This field is a user defined string and will be used as the identity for that resource.
This value must be unique, contains alphanumeric character (any casing). Note, the '-' character is also allowed.
The maximum length for the value is 20 characters. This value is configured in the [`/src/config/app_config.yml`](/src/config/app_config.yml) for the element `resourceIdMaxLength`.


Once deployed, you can find that resource on AWS Console, EC2 Load Balancers.
The deployer follows a naming convention when creating resources. All resources have the following format `[user config filename prefix]-[deploy config filename prefix]-[resource_id]`
For example, if you've run the deployer with a command `ruby main.rb -c jsmith.local.json -d hello.json` with `hello.json` the resource definition above, you'll find an ELB resource created with a name of `jsmith-hello-appelb1`.

### listeners

This field is required. It's an array of service identities. Typically only 1 service identity is specified, and the deployer will configure all the instances of this service to be load balanced.
Note, the deployer will generate validation errors if any of the service identity provided are not defined in the deploy config.
