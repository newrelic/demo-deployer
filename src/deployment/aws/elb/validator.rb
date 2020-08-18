require "./src/common/logger/logger_factory"
require "./src/common/validators/validator"
require "./src/common/validators/port_exist_validator"

require "./src/infrastructure/definitions/aws/elb_resource"
require "./src/deployment/aws/allowed_listeners_validator"

module Deployment
  module Aws
    module Elb
      class Validator

        def initialize(services,
          context,
          allowed_listeners_validator = nil)

          @services = services
          @context = context
          @allowed_listeners_validator = allowed_listeners_validator || Deployment::Aws::AllowedListenersValidator.new(Infrastructure::Definitions::Aws::ElbResource, services, @context)
        end

        def execute(resources)
          Common::Logger::LoggerFactory.get_logger().debug("Deployment/Aws/Elb/Validator execute()")
          validators = [
            lambda { return @allowed_listeners_validator.execute(resources) }
          ]
          validator = Common::Validators::Validator.new(validators)
          return validator.execute()
        end

      end
    end
  end
end