require "./src/common/logger/logger_factory"
require "./src/common/validators/validator"

require "./src/common/validators/port_exist_validator"

module Deployment
  module Azure
    module Vm
      class Validator

        def initialize(services, 
          port_exist_validator = nil)

          @services = services
          @port_exist_validator = port_exist_validator || Common::Validators::PortExistValidator.new(services)
        end

        def execute(resources)
          Common::Logger::LoggerFactory.get_logger().debug("Deployment/Azure/Vm/Validator execute()")
          validators = [
            lambda { return @port_exist_validator.execute(resources) }
          ]
          validator = Common::Validators::Validator.new(validators)
          return validator.execute()
        end

      end
    end
  end
end