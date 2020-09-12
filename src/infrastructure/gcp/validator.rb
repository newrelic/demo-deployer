require_relative "type_validator_factory"

module Infrastructure
  module Gcp
    class Validator

      def initialize(context, type_validator_factory = nil)
        @context = context
        @type_validator_factory = type_validator_factory
      end

      def execute(resources)
        validators = []

        lambdas = get_type_validators(resources)
        validators.concat(lambdas)

        validator = Common::Validators::Validator.new(validators)
        return validator.execute()
      end

      private
      def get_type_validators(resources)
        return get_type_validator_factory().create_validators(resources)
      end

      def get_app_config_provider()
        return @context.get_app_config_provider()
      end

      def get_type_validator_factory()
        return @type_validator_factory ||= TypeValidatorFactory.new(get_app_config_provider())
      end

    end
  end
end