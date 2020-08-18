require './src/infrastructure/definitions/aws/aws_resource'

module Infrastructure
  module Definitions
    module Aws
      class ElbResource < AwsResource

        def initialize (id, credential, listeners, user_name, tags)
          super(id, "elb", credential, AwsResource::ELB_GROUP_ID)

          @listeners = listeners
          @user_name = user_name
          @tags = tags
        end

        def get_listeners()
          return @listeners
        end

        def get_user_name()
          return @user_name
        end

        def get_tags()
          return @tags
        end

      end
    end
  end
end
