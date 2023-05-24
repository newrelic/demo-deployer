require "./src/common/validators/file_exist"
require "./src/common/validators/validator"
require_relative "aws/api_key_validator"

module UserConfig
  module Validators
    class AwsValidator

      def initialize(
          api_key_exist_validator = nil,
          secret_key_validator = nil,
          region_validator = nil,
          api_key_validator = nil
        )
        @api_key_exist_validator = api_key_exist_validator || Common::Validators::FieldExistValidator.new("apiKey", "apiKey is missing for aws credential:")
        @secret_key_validator = secret_key_validator || Common::Validators::FieldExistValidator.new("secretKey", "secretKey is missing for aws credential:")
        @region_validator = region_validator || Common::Validators::FieldExistValidator.new("region", "region is missing for aws credential:")
        @api_key_validator = api_key_validator || UserConfig::Validators::Aws::ApiKeyValidator.new()
      end

      def execute(aws_configs)
        validators = [
          lambda { return @api_key_exist_validator.execute(aws_configs) },
          lambda { return @secret_key_validator.execute(aws_configs) },
          lambda { return @region_validator.execute(aws_configs) },
          lambda { return @api_key_validator.execute(aws_configs) }
        ]

        validator = Common::Validators::Validator.new(validators)
        return validator.execute()
      end

    end
  end
end