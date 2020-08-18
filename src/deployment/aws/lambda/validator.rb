require "./src/common/logger/logger_factory"
require "./src/common/validators/validator"

require_relative "single_service_validator"

module Deployment
  module Aws
    module Lambda
      class Validator

        def initialize(services, single_service_validator = nil)
          @services = services
          @single_service_validator = single_service_validator
        end

        def execute(resources)
          Common::Logger::LoggerFactory.get_logger().debug("Deployment/Aws/Lambda/Validator execute()")
          validators = [
            lambda { return get_single_service_validator().execute(resources) }
          ]
          validator = Common::Validators::Validator.new(validators)
          return validator.execute()
        end

        private
        def get_single_service_validator()
          return @single_service_validator ||= SingleServiceValidator.new(@services)
        end

      end
    end
  end
end