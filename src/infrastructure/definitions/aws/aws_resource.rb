require './src/infrastructure/definitions/resource_data'

module Infrastructure
  module Definitions
    module Aws
      class AwsResource < ResourceData

        EC2_GROUP_ID = 1
        LAMBDA_GROUP_ID = 1
        S3_GROUP_ID = 1
        ELB_GROUP_ID = 2
        R53_GROUP_ID = 3

        def initialize (id, type, credential, provision_group)
          super(id, "aws", provision_group)
          @type = type
          @credential = credential
          @provision_group = provision_group
        end

        def get_type()
          return @type
        end

        def get_credential()
          return @credential
        end

        def get_group()
          return @provision_group
        end

      end
    end
  end
end