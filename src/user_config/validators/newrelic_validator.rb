require "./src/common/validators/validator"

require "./src/common/validators/field_exist_validator"

module UserConfig
  module Validators
    class NewRelicValidator

      def initialize(
          license_key_exist_validator = nil
        )
        @license_key_exist_validator = license_key_exist_validator || Common::Validators::FieldExistValidator.new("licenseKey", "User configuration for newrelic is missing licenseKey")
      end

      def execute(newrelic_configs)
        validators = [
          lambda { return @license_key_exist_validator.execute(newrelic_configs) }
        ]

        validator = Common::Validators::Validator.new(validators)
        return validator.execute()
      end

    end
  end
end