# Resource merge fields

A resource merge field has the following syntax `[resource:host1:property]` where property can be any of the below:

## display_name property

This will be replaced with the resource `display_name` from the deploy config, or defaults to the `id` value if not specified.

## url property

This will be replaced at deploy time by the actual resource URL.

## ip property

This will be the public IP for the resource, typically a VM host.

## private_dns_name property

For VM resource type (AWS/EC2 only), this will be the private DNS name associated with the instance

## instance_id property

For VM resource type (AWS/EC2 only), this will be the internal identity of the instance

