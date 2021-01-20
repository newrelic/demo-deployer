# Output

This section and all the fields within are optional.

At the moment, output is just a section containing the footnote field.

## Footnote

The footnote field takes the text specified in the field and writes it as output during the deployment. This output follows the summary, and precedes the output containing the file location of the deployer output. See the next section below for an example.

The footnote field accepts a `String` or `Array<String>` representation of text. In the case of an `Array<String>` being submitted, the resulting output text is a concatentation of the elements of the array with newline characters inbetween the elements -- each element is written on its own line.  

Finally, [merge fields](../merge_fields/README.md) can be embedded within the field's text, and will be substituted for their values before being written out.

### Footnote Location

```text
[INFO] Executing Deployment
[✔] Parsing and validating Deployment configuration success
[✔] Provisioner success
[✔] Installing 1 Definitions success
[INFO] Deployment successful!

Deployed Resources:
    .
    .

Installed Services:
    .
    .

Completed at 2021-01-15 21:18:31 +0000

--------> This is where the footnote is written during output. <--------

[INFO] This deployment summary can also be found in:
[INFO]   /tmp/user-deploy/deploy_summary.txt
```

## Examples

### Example 1 -- Simple String Footnote

Config:

```json
{
  "output": {
    "footnote": "An example footnote"
  }
}
```

Output:

```text
An example footnote
```

### Example 2 -- Simple String Array Footnote

Config:

```json
{
  "output": {
    "footnote": [
        "An",
        "example",
        "footnote"
    ]
  }
}
```

Output:

```text
An example footnote
```

### Example 3 -- Footnote with Merge Fields

Config:

```json
{
    "global_tags": {
        "dxOwningTeam": "DemoX",
        "dxEnvironment": "development",
        "dxDepartment": "Area51",
        "dxProduct": "Hello"
    },
    "services": [
        {
            "id": "mariadb1",
            "source_repository": "-b main https://github.com/newrelic/demo-services.git",
            "deploy_script_path": "deploy/mariadb/linux/roles",
            "port": 6002,
            "destinations": [
                "host1"
            ],
            "params": {
                "database_user": "demotron",
                "database_password": "[credential:secrets:database_password]",
                "database_root_password": "[credential:secrets:database_root_password]"
            }
        }
    ],
    "resources": [
        {
            "id": "host1",
            "display_name": "Hello-Host1",
            "provider": "aws",
            "type": "ec2",
            "size": "t3.micro"
        }
    ],
    "instrumentations": {},
    "output": {
            "footnote": [
                "------------------------- This is a test footnote: -------------------------",
                "Line 1 - This is host1's ip: [resource:host1:ip]",
                "Line 2 - This is host1's display name: [resource:host1:display_name]",
                "Line 3 - This is the mariadb1 root password: [credential:secrets:database_root_password]",
                "Line 4 - This is the mariadb1 port: [service:mariadb1:port]",
                "Line 5 - This is the mariadb1 url: [service:mariadb1:url]",
                "Line 6 - This is the global deployment_name: [global:deployment_name]",
                "Last line to write",
                ""
            ]
    }
}
```

Output:

```text
------------------------- This is a test footnote: -------------------------
Line 1 - This is host1's ip: 1.2.3.4
Line 2 - This is host1's display name: Hello-Host1
Line 3 - This is the mariadb1 root password: somerandompassword
Line 4 - This is the mariadb1 port: 1234
Line 5 - This is the mariadb1 url: http://1.2.3.4:1234
Line 6 - This is the global deployment_name: user-deploy
Last line to write
```
