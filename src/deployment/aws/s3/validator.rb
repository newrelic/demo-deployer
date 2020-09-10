require "./src/common/logger/logger_factory"
require "./src/common/validators/validator"

module Deployment
  module Aws
    module S3
      class Validator

        def initialize(services,
            context
          )
          @services = services
          @context = context
        end

        def execute(resources)
          Common::Logger::LoggerFactory.get_logger().debug("Deployment/Aws/S3/Validator execute()")
          validators = [
            # No validators yet, add new rules here
          ]
          validator = Common::Validators::Validator.new(validators)
          return validator.execute()
        end

      end
    end
  end
end