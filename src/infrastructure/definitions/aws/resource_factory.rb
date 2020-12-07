require  "./src/infrastructure/definitions/aws/ec2_resource"
require  "./src/infrastructure/definitions/aws/elb_resource"
require  "./src/infrastructure/definitions/aws/lambda_resource"
require  "./src/infrastructure/definitions/aws/r53ip_resource"
require  "./src/infrastructure/definitions/aws/s3_resource"

module Infrastructure
  module Definitions
    module Aws
      class ResourceFactory

        def initialize(user_config_provider, tag_provider, default_user_name = "ec2-user")
          @user_config_provider = user_config_provider
          @tag_provider = tag_provider
          @default_user_name = default_user_name
        end

        def create(config_resource)
          resource_id = config_resource["id"]
          tags = @tag_provider.get_resource_tags(resource_id)
          user_name = (config_resource["user_name"] || @default_user_name)
          credential = get_credential()

          case config_resource["type"]
            when "ec2"
              ec2_resource = Ec2Resource.new(resource_id, credential, config_resource["size"], user_name, tags, config_resource["cpu_credit_specification"])
              ami_name = config_resource["ami_name"]
              unless (ami_name.nil? || ami_name.empty?)
                ec2_resource.set_ami_name(ami_name)
              end
              is_windows = config_resource["is_windows"]
              unless is_windows.nil?
                ec2_resource.set_windows(is_windows)
              end
              return ec2_resource

            when "elb"
              return ElbResource.new(resource_id, credential, config_resource["listeners"], user_name, tags)

            when "lambda"
              return LambdaResource.new(resource_id, credential, user_name, tags)

            when "r53ip"
              domain = config_resource["domain"]
              listeners = config_resource["listeners"]
              reference_id = config_resource["reference_id"]
              return R53IpResource.new(resource_id, credential, domain, listeners, reference_id)

            when "s3"
              bucket_name = config_resource["bucket_name"]
              return S3Resource.new(resource_id, credential, bucket_name, tags)
          end

          return nil
        end

        private
        def get_credential()
          return @user_config_provider.get_aws_credential()
        end

      end
    end
  end
end