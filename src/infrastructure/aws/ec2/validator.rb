require "./src/common/validators/validator"
require "./src/common/validators/size_validator"
require "./src/infrastructure/aws/ec2/pem_key_validator"

module Infrastructure
  module Aws
    module Ec2
      class Validator

        def initialize(context, size_validator = nil, pem_key_validator = nil)
          @context = context
          @size_validator = size_validator
          @pem_key_validator = pem_key_validator
        end

        def execute(resources)
          validators = [
            lambda { return get_size_validator().execute(resources) },
            lambda { return get_pemkey_validator().execute() }
          ]
          validator = Common::Validators::Validator.new(validators)
          return validator.execute()
        end

        private
        def get_size_validator()
          return @size_validator ||= Common::Validators::SizeValidator.new(get_supported_sizes())
        end

        def get_pemkey_validator()
          return @pem_key_validator ||= Infrastructure::Aws::EC2::PemKeyValidator.new(@context)
        end

        def get_supported_sizes()
          return @context.get_app_config_provider().get_aws_ec2_supported_sizes()
        end

      end
    end
  end
end