# Azure VM resource type

To define a VM resource type, the following field are required:

```json
{
    "resources":[
        {
            "id": "host1",
            "provider": "azure",
            "type": "vm",
            "size": "Standard_B1s"
        }
    ]
}
```

## OS

Currently, the deployer creates a VM with a Linux instance of CentOS from OpenLogic.

### id

This field is a user defined string and will be used as the identity for that resource.
This value must be unique, contains alphanumeric character (any casing). Note, the '-' character is also allowed.
The maximum length for the value is 20 characters. This value is configured in the [`/src/app_config.yml`](/src/app_config.yml) for the element `resourceIdMaxLength`.

Once deployed, you can find that resource on the Azure portal, Virtual Machines.
The deployer follows a naming convention when creating resources. All resources have the following format `[user config filename prefix]-[deploy config filename prefix]-[resource_id]`
For example, if you've run the deployer with a command `ruby main.rb -c jsmith.local.json -d hello.json` with `hello.json` the resource definition above, you'll find a VM resource created with a name of `jsmith-hello-host1`.

### size

This field specify which size to use for the VM instance. The values can be looked up on Azure documentation, for example for the B-series https://docs.microsoft.com/en-us/azure/virtual-machines/sizes-b-series-burstable . The value of `Standard_B1s` is a possible size.
