require_relative "port_type_validator"
require_relative "port_range_validator"
require_relative "port_destination_validator"

module Services
  class PortValidator

    def initialize(
      port_type_validator = PortTypeValidator.new("The following services require a valid integer for port number:"),
      port_range_validator = PortRangeValidator.new([[80,80],[1024,65535]], "The following services have a port assignment that does not fall within these ranges:"),
      port_destination_validator = PortDestinationValidator.new("The following resources are configured to host multiple services on the same port:")
      )
      @port_type_validator = port_type_validator
      @port_range_validator = port_range_validator
      @port_destination_validator = port_destination_validator
    end

    def execute(services)
      validators = [
        lambda { return @port_type_validator.execute(services) },
        lambda { return @port_range_validator.execute(services) },
        lambda { return @port_destination_validator.execute(services) }
      ]
      
      validator = Common::Validators::Validator.new(validators)
      return validator.execute()
    end
  end
end