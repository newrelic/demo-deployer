require "./src/common/validators/validator_factory"
require_relative "compute/validator"

module Deployment
  module Gcp
    class TypeValidatorFactory < Common::Validators::ValidatorFactory

      def initialize(services, context)
        @services = services
        @context = context
        super(
          {
            "compute" => Compute::Validator.new(@services)
          },
          lambda {|resource| return resource.get_type()},
          lambda {|validator| return validator}
        )
      end

    end
  end
end