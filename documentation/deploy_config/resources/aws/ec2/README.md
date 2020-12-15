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
The maximum length for the value is 20 characters. This value is configured in the [`/src/app_config.yml`](/src/app_config.yml) for the element `resourceIdMaxLength`.

Once deployed, you can find that resource on AWS Console, EC2 dashboard.
The deployer follows a naming convention when creating resources. All resources have the following format `[user config filename prefix]-[deploy config filename prefix]-[resource_id]`
For example, if you've run the deployer with a command `ruby main.rb -c jsmith.local.json -d hello.json` with `hello.json` the resource definition above, you'll find an EC2 resource created with a name of `jsmith-hello-host1`.

### ami_name

Optional, this field specify which ami to use. The default ami name is `amzn2-ami-hvm-2.0.20190228-x86_64-gp2`.
The value is used as a filter pattern to find the most recent AMI of a resultset.
For example `"ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-????????.1"` will search and find the most recent Ubuntu 18.04 version.
Note, when using an OS having a different user than the default `ec2-user` name, the field `user_name` should be used to configure which user name to use for SSH.

### user_name

Optional, this field specify which user to use for SSH. By default the value of `ec2-user` is used, which is the default user for AWS Linux AMIs. For example, a `user_name` of `ubuntu` should be used when provisioning a Ubuntu linux instance.

### size

This field specify which size to use for the EC2 instance. All the possible values are configured in the [`/src/app_config.yml`](/src/app_config.yml) for the element `awsEc2SupportedSizes`.
For example `t3.micro` is a possible instance size.

### cpu_credit_specification

This field is **optional**, it specifies if T2 instances should buy more CPU credits when they runs out. The available values are "standard" and "unlimited".

## Windows

The deployer can provision Windows server instances on AWS/EC2.
the resource element `"is_windows": true` is required. Here is an example for creating a Windows 2019 Server:

```
{
  "resources": [
    {
      "id": "win1",
      "provider": "aws",
      "type": "ec2",
      "size": "t2.micro",
      "is_windows": true,
      "ami_name": "Windows_Server-2019-English-Full-HyperV-*",
      "user_name": "Administrator"
    }
  ]
}
```

Note, the Administrator password is auto-generated and can be obtained using the pem key file on the AWS console (right click the instance and select `Connect`). With the instance public IP and the Administrator/Password you can login using the `Remote Desktop Connection` tool.
Also, the administrator password is included in the `artifact.json` output file of that ec2 instance. As an example, you can view the content of the file with the following command `cat /tmp/user-windows/win1/artifact.json`
