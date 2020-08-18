require "./src/common/validators/file_exist"
require "./src/common/validators/validator"

module UserConfig
  module Validators
    class AwsValidator

      def initialize(
          secret_file_validator = nil,
          api_key_validator = nil,
          secret_key_validator = nil,
          secret_key_path_validator = nil,
          region_validator = nil
        )
        @secret_file_validator = secret_file_validator || Common::Validators::FileExist.new("A valid secret file could not be found in the path defined")
        @api_key_validator = api_key_validator || Common::Validators::FieldExistValidator.new("apiKey", "apiKey is missing for aws credential:")
        @secret_key_validator = secret_key_validator || Common::Validators::FieldExistValidator.new("secretKey", "secretKey is missing for aws credential:")
        @secret_key_path_validator = secret_key_path_validator || Common::Validators::FieldExistValidator.new("secretKeyPath", "secretKeyPath is missing for aws credential:")
        @region_validator = region_validator || Common::Validators::FieldExistValidator.new("region", "region is missing for aws credential:")
      end

      def execute(aws_configs)
        validators = [
          lambda { return @api_key_validator.execute(aws_configs) },
          lambda { return @secret_key_validator.execute(aws_configs) },
          lambda { return @secret_key_path_validator.execute(aws_configs) },
          lambda { return @region_validator.execute(aws_configs) }
        ]

        aws_configs.each do |aws_config|
          validators.push(lambda { return @secret_file_validator.execute(aws_config["secretKeyPath"]) } )
        end

        validator = Common::Validators::Validator.new(validators)
        return validator.execute()
      end

    end
  end
end