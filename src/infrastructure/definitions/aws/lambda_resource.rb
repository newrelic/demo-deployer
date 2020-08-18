require './src/infrastructure/definitions/aws/aws_resource'

module Infrastructure
  module Definitions
    module Aws
      class LambdaResource < AwsResource

        def initialize (id, credential, user_name, tags)
          super(id, "lambda", credential, AwsResource::EC2_GROUP_ID)
          @user_name = user_name
          @api_id = nil
          @tags = tags
        end

        def get_user_name()
          return @user_name
        end

        def get_api_id()
          return @api_id
        end

        def set_api_id(value)
          @api_id = value
        end

        def get_tags()
          return @tags
        end

      end
    end
  end
end