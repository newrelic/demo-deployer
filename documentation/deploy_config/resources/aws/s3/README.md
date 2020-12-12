# AWS S3 resource type

You can use a `s3` type to create an S3 bucket.

## Pre-requisite

The deployer will validate a `bucket_name` is provided.

## Configuration

```json
{
    "resources":[
        {
            "id": "bucket1",
            "provider": "aws",
            "type": "s3",
            "bucket_name": "mybucket1"
        }
    ]
}
```

## id

This field is a user defined string and will be used as the identity for that resource.
This value must be unique, contains alphanumeric character (any casing). Note, the '-' character is also allowed.
The maximum length for the value is 20 characters. This value is configured in the [`/src/app_config.yml`](/src/app_config.yml) for the element `resourceIdMaxLength`.

Once deployed, you can find that resource on AWS Console, S3.

## bucket_name

This field represents the name of the bucket.

Please refer to the AWS Rules for bucket naming at https://docs.aws.amazon.com/AmazonS3/latest/dev/BucketRestrictions.html
