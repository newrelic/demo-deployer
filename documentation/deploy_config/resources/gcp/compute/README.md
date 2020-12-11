# GCP Compute resource type

To define a `Compute` resource type, the following field are required:

```json
{
    "resources":[
        {
            "id": "host1",
            "provider": "gcp",
            "type": "compute",
            "size": "e2-micro"
        }
    ]
}
```

## OS

Currently, the deployer creates an instance with a Linux CentOS 7 image.

### id

This field is a user defined string and will be used as the identity for that resource.
This value must be unique, contains alphanumeric character (any casing). Note, the '-' character is also allowed.
The maximum length for the value is 20 characters. This value is configured in the [`/src/app_config.yml`](/src/app_config.yml) for the element `resourceIdMaxLength`.

Once deployed, you can find that resource on the GCP console `Compute Engine`.
The deployer follows a naming convention when creating resources. All resources have the following format `[user config filename prefix]-[deploy config filename prefix]-[resource_id]`
For example, if you've run the deployer with a command `ruby main.rb -c jsmith.local.json -d hello.json` with `hello.json` the resource definition above, you'll find a Compute resource created with a name of `jsmith-hello-host1`.

### size

This field specify which size to use for the instance. The values can be looked up on the GCP documentation https://cloud.google.com/compute/docs/machine-types .
For example e2-micro is a 2vCPU 1GB size.

## Tags consideration

GCP has strict restrictions for tags. Both key and value must be lowercase, and some characters like '.' are not allowed. See https://cloud.google.com/compute/docs/labeling-resources#label_format for more information.
The deployer will attempt to make any key/value lower case, and any '.' will be removed.
Note, if any instrumentation is used (such as newrelic), tags can then be handled without the GCP restrictions and any substitution, since those tags won't be transiting through the GCP resources directly.

