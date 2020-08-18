require 'json'

require "./src/common/validation_error"

module Services
  class PortRangeValidator

    def initialize(available_ranges, error_message = nil)
      @available_ranges = available_ranges || []
      @error_message = error_message || "Error"
    end

    def execute(services)
      invalid = []

      (services || []).each do |service|
        begin
          port = service['port']
          number = Integer(port)
          if @available_ranges.all? { |available_range| contain_port(available_range, number) == false }
            invalid.push(JSON.generate(service))
          end
        rescue ArgumentError, TypeError
        end
      end

      if invalid.length>0
        return "#{@error_message} #{@available_ranges.join(", ")} #{invalid.join(", ")}"
      end

      return nil
    end

    private

    def contain_port(available_range, port)
      if available_range.length != 2
        message = "Invalid port range defined. Expecting 2 values but got #{available_range.length} with array [#{available_range.join(",")}]"
        raise Common::ValidationError.new(message)
      end
      return (port >= available_range[0]) && (port <= available_range[1])
    end

  end
end
