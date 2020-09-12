require "./src/common/validators/validator_factory"

require "./src/user_config/validators/aws_validator"
require "./src/user_config/validators/azure_validator"
require "./src/user_config/validators/newrelic_validator"
require "./src/user_config/validators/gcp_validator"
require "./src/user_config/validators/git_validator"

module UserConfig
  module Validators
    class ProviderValidatorFactory < Common::Validators::ValidatorFactory

      def initialize()
        super(
          { "aws" => AwsValidator,
            "azure" => AzureValidator,
            "newrelic" => NewRelicValidator,
            "gcp" => GcpValidator ,
            "git" => GitValidator
          },
          lambda {|parsed| return parsed["provider"]},
          lambda {|validator_type| return validator_type.new()},
          nil,
          lambda { return nil }
        )
      end

    end
  end
end