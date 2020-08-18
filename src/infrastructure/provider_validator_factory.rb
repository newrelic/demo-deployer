require "./src/common/validators/validator_factory"
require_relative "aws/validator"
require_relative "azure/validator"

module Infrastructure
  class ProviderValidatorFactory < Common::Validators::ValidatorFactory

    def initialize(app_config_provider)
      @app_config_provider = app_config_provider
      super(
        { "aws" => Aws::Validator,
          "azure" => Azure::Validator },
        lambda {|resource| return resource['provider']},
        lambda {|validator_type| return validator_type.new(@app_config_provider)}
      )
    end

  end
end