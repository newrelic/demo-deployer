require "./src/common/logger/logger_factory"
require "./src/common/validators/validator"

require_relative "type_validator_factory"

module Deployment
  module Gcp
    class Validator

      def initialize(services, context, type_validator_factory = nil, credential_exist_validator = nil)
        @services = services
        @context = context
        @type_validator_factory = type_validator_factory
        @credential_exist_validator = credential_exist_validator
      end

      def execute(resources)
        Common::Logger::LoggerFactory.get_logger().debug("Deployment/Gcp/Validator execute()")
        validators = [
          lambda { return get_credential_exist_validator().execute("gcp") }
        ]

        lambdas = get_type_validators(resources)
        validators.concat(lambdas)

        validator = Common::Validators::Validator.new(validators)
        return validator.execute()
      end

      private
      def get_type_validators(resources)
        return  get_type_validator_factory().create_validators(resources)
      end

      def get_type_validator_factory()
        return @type_validator_factory ||= TypeValidatorFactory.new(@services, @context)
      end

      def get_credential_exist_validator()
        user_config_provider = @context.get_user_config_provider()
        return @credential_exist_validator ||= Deployment::CredentialExistValidator.new(user_config_provider)
      end

    end
  end
end