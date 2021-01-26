require "./src/common/validation_error"

require_relative "validator"
require_relative "provider"

module Deployment
  class Orchestrator

    def initialize(context, validator = Deployment::Validator.new)
      @context = context
      @validator = validator
    end

    def execute()
      log_token = Common::Logger::LoggerFactory.get_logger().add_sub_task('Validating instrumentations')
      validation_errors = @validator.execute(@context)
      unless validation_errors.empty?
        log_token.error()
        raise Common::ValidationError.new("Deployment validation has failed", validation_errors)
      end
      provider = Deployment::Provider.new(@context)
      @context.set_deployment_provider(provider)
      log_token.success()
      return provider
    end
  end
end
