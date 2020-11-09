require './src/infrastructure/definitions/aws/aws_resource'

module Infrastructure
  module Definitions
    module Aws
      class Ec2Resource < AwsResource

        def initialize (id, credential, size, user_name, tags, cpu_credit_specification=nil)
          super(id, "ec2", credential, AwsResource::EC2_GROUP_ID)

          @size = size
          @user_name = user_name
          @ami_name = "amzn2-ami-hvm-2.0.20190228-x86_64-gp2"
          @tags = tags
          @cpu_credit_specification = cpu_credit_specification
        end

        def get_size()
          return @size
        end

        def get_user_name()
          return @user_name
        end

        def get_ami_name()
          return @ami_name
        end
        def set_ami_name(ami_name)
          @ami_name = ami_name
        end

        def get_tags()
          return @tags.merge({})
        end

        def get_cpu_credit_specification()
          return @cpu_credit_specification
        end

      end
    end
  end
end