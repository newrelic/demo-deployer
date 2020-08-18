require 'json'

module Services
  class PortTypeValidator

    def initialize(error_message = nil)
      @error_message = error_message || "Error"
    end

    def execute(services)
      invalid = []

      (services || []).each do |service|
        begin
          port = service['port']
          Integer(port)
        rescue ArgumentError
          invalid.push(JSON.generate(service))
        rescue TypeError
        end
      end

      if invalid.length>0
        return "#{@error_message} #{invalid.join(", ")}"
      end

      return nil
    end

  end
end
