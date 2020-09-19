# AWS EC2 resource type

To define an EC2 resource type, the following field are required:

```json
{
    "resources":[
        {
            "id": "host1",
            "provider": "aws",
            "type": "ec2",
            "size": "t3.micro",
            "cpu_credit_specification": "standard"
        }
    ]
}
```

## OS

Currently, the deployer creates an EC2 with the latest Amazon Linux2 image. More details about this image can be found at https://aws.amazon.com/amazon-linux-2/release-notes/

### id

This field is a user defined string and will be used as the identity for that resource.
This value must be unique, contains alphanumeric character (any casing). Note, the '-' character is also allowed.
The maximum length for the value is 20 characters. This value is configured in the [`/src/config/app_config.yml`](/src/config/app_config.yml) for the element `resourceIdMaxLength`.

Once deployed, you can find that resource on AWS Console, EC2 dashboard.
The deployer follows a naming convention when creating resources. All resources have the following format `[user config filename prefix]-[deploy config filename prefix]-[resource_id]`
For example, if you've run the deployer with a command `ruby main.rb -c jsmith.local.json -d hello.json` with `hello.json` the resource definition above, you'll find an EC2 resource created with a name of `jsmith-hello-host1`.

### size

This field specify which size to use for the EC2 instance. All the possible values are configured in the [`/src/config/app_config.yml`](/src/config/app_config.yml) for the element `awsEc2SupportedSizes`.
For example `t3.micro` is a possible instance size.

### cpu_credit_specification

This field is **optional**, it specifies if T2 instances should buy more CPU credits when they runs out. The available values are "standard" and "unlimited".