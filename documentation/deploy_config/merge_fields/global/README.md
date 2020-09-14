# Global merge fields

Global merge fields are added to all the other types of merge field definitions (services, resources...)
A global merge field has the following syntax `[global:property]` where property can be any of the below:

## user_name property

This will be replaced at deploy time by the actual user name. The user name is the first part of the user config filename.

For example, running the deployer with the command `ruby main.rb -c jsmith.json -d singleapp.json` would generate a user name of `jsmith`.

## deploy_name property

This will be replaced at deploy time by the actual deploy name. The deploy name is the first part of the deploy config filename.

For example, running the deployer with the command `ruby main.rb -c jsmith.json -d singleapp.json` would generate a deploy name of `singleapp`.

## deployment_name property

This will be replaced at deploy time by the actual deployment name. A deployment name is the combination of a `user` name with a `deploy` name separated by a `-` character.

For example, running the deployer with the command `ruby main.rb -c jsmith.json -d singleapp.json` would generate a deployment name of `jsmith-singleapp`.
