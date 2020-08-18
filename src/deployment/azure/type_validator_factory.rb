require "./src/common/validators/validator_factory"
require_relative "vm/validator"

module Deployment
  module Azure
    class TypeValidatorFactory < Common::Validators::ValidatorFactory

      def initialize(services, context)
        @services = services
        @context = context
        super(
          {
            "vm" => Vm::Validator.new(@services)
          },
          lambda {|resource| return resource.get_type()},
          lambda {|validator| return validator}
        )
      end

    end
  end
end