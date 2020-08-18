require "./src/common/validators/validator"

module Deployment
  module Aws
    class NilValidator

      def initialize(services)
        @services = services
      end

      def execute(resources)
        validators = []
        validator = Common::Validators::Validator.new(validators)
        return validator.execute()
      end
    end
  end
end