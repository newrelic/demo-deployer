require "./src/instrumentation/validators/target_exists_validator"
require "./src/instrumentation/validators/required_keys_validator"
require "./src/instrumentation/validators/instrument_only_once_validator"
require "./src/common/validators/validator"

module Instrumentation
  module Validators
    class ResourceValidators

      def initialize(
          target_exists_validator = Instrumentation::Validators::TargetExistsValidator.new("resource_ids", "Invalid resource reference(s) found in instrumentations: ")
          )
        @target_exists_validator = target_exists_validator
      end

      def execute(parsed_instrumentors, resource_ids)
        validators = [
          lambda { return @target_exists_validator.execute(parsed_instrumentors, resource_ids) }
        ]

        validator = Common::Validators::Validator.new(validators)
        return validator.execute()
      end

    end
  end
end
