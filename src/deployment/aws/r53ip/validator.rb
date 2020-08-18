require "./src/common/logger/logger_factory"
require "./src/common/validators/validator"
require "./src/deployment/aws/allowed_listeners_validator"
require "./src/deployment/aws/allowed_reference_validator"
require "./src/infrastructure/definitions/aws/r53ip_resource"
require "./src/infrastructure/definitions/aws/elb_resource"

module Deployment
  module Aws
    module R53Ip
      class Validator

        def initialize(services,
            context,
            allowed_listeners_validator = nil,
            allowed_reference_validator = nil
          )
          @services = services
          @context = context
          @allowed_listeners_validator = allowed_listeners_validator || Deployment::Aws::AllowedListenersValidator.new(Infrastructure::Definitions::Aws::ElbResource, services, @context)
          @allowed_reference_validator = allowed_reference_validator || Deployment::Aws::AllowedReferenceValidator.new(Infrastructure::Definitions::Aws::R53IpResource, ["elb"], @context)
        end

        def execute(resources)
          Common::Logger::LoggerFactory.get_logger().debug("Deployment/Aws/R53Ip/Validator execute()")
          validators = [
            lambda { return @allowed_listeners_validator.execute(resources) },
            lambda { return @allowed_reference_validator.execute(resources) }
          ]
          validator = Common::Validators::Validator.new(validators)
          return validator.execute()
        end

      end
    end
  end
end