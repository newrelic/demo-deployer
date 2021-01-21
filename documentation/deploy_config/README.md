# Deploy config

The deploy config file contains the definition of everything that needs to be deployed. This is typically multiple resources element, services to install on top of the defined resources, and optionally any instrumentation to install.

The overall structure of a deploy config looks like this:

```json
{

  "resources": [
  ],

  "services": [
  ],

  "instrumentations": {
    "resources": [
    ],
    "services": [
    ],
  },

  "global_tags": {
    "my_tag_key": "my_tag_value",
    "another_tag_key": "another_tag_value"
  },

  "output": {
    "footnote" : [
      "First line of a footnote.",
      "Second line of a footnote.",
      "Third line of a footnote."
    ]
  }

}
```

Please refer to the sections below for more details.

* [Resources](resources/README.md)
* [Services](services/README.md)
* [Instrumentation](instrumentations/README.md)
* [Global Tags](global_tags/README.md)
* [Output](output/README.md)

In addition, the deployer can dynamically replace some `merge fields` in the deploy config with their corresponding value which is determined at deploy time. For more information see the section below.

* [Merge Fields](merge_fields/README.md)
