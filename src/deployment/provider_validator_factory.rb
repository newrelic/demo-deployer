require "./src/common/validators/validator_factory"
require_relative "aws/validator"
require_relative "azure/validator"
require_relative "gcp/validator"

module Deployment
  class ProviderValidatorFactory < Common::Validators::ValidatorFactory

    def initialize(services, context)
      @services = services
      @context = context
      super(
        { "aws" => Aws::Validator,
          "azure" => Azure::Validator,
          "gcp" => Gcp::Validator
        },
        lambda {|resource| return resource.get_provider()},
        lambda {|validator_type| return validator_type.new(@services, context)}
      )
    end

  end
end