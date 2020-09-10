require './src/infrastructure/definitions/aws/aws_resource'

module Infrastructure
  module Definitions
    module Aws
      class S3Resource < AwsResource

        def initialize (id, credential, bucket_name)
          super(id, "s3", credential, AwsResource::S3_GROUP_ID)
          @bucket_name = bucket_name
        end

        def get_bucket_name()
          return @bucket_name
        end

      end
    end
  end
end
