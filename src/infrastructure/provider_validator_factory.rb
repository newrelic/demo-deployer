require "./src/common/validators/validator_factory"
require_relative "aws/validator"
require_relative "azure/validator"
require_relative "gcp/validator"

module Infrastructure
  class ProviderValidatorFactory < Common::Validators::ValidatorFactory

    def initialize(context)
      @context = context
      super(
        { "aws" => Aws::Validator,
          "azure" => Azure::Validator,
          "gcp" => Gcp::Validator 
        },
        lambda { |resource| return resource['provider'] },
        lambda { |validator_type| return validator_type.new(@context) }
      )
    end

  end
end