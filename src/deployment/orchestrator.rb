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
      validation_errors = @validator.execute(@context)
      unless validation_errors.empty?
        raise Common::ValidationError.new("Deployment validation has failed", validation_errors)
      end
      provider = Deployment::Provider.new(@context)
      @context.set_deployment_provider(provider)
      return provider
    end
  end
end
