# AWS Lambda resource type

You can use a `lambda` type to define an AWS Lambda resource. This resource will be associated in a one-to-one manner with specific service definition.
The below json illustrate the structure of this resource definition.

```json
{
    "resources": [
        {
            "id": "app1",
            "provider": "aws",
            "type": "lambda"
        }
    ]
}
```

### id

This field is a user defined string and will be used as the identity for that resource.
This value must be unique, contains alphanumeric character (any casing). Note, the '-' character is also allowed.
The maximum length for the value is 20 characters. This value is configured in the [`/src/config/app_config.yml`](/src/config/app_config.yml) for the element `resourceIdMaxLength`.


Once deployed, you can find that resource on AWS Console, Lambda.
The deployer follows a naming convention when creating resources. All resources have the following format `[user config filename prefix]-[deploy config filename prefix]-[resource_id]`
For example, if you've run the deployer with a command `ruby main.rb -c jsmith.local.json -d hello.json` with `hello.json` the resource definition above, you'll find a Lambda resource created with a name of `jsmith-hello-appelb1`.
