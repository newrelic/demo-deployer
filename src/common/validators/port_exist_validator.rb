require "./src/common/logger/logger_factory"
require "json"

module Common
  module Validators
    class PortExistValidator

      def initialize(services, error_message = nil)
        @services = services || []
        @error_message = error_message || "The following services are missing a port definition when using an host resource:"
      end

      def execute(resources)
        invalid = []

        (resources || []).each do |resource|
          resource_id = resource.get_id()
          service_ids = []
          @services.each do |service|
            if service.get_destinations().any? { |destination| destination == resource_id }
              if service.get_port().nil?
                service_ids.push(service.get_id())
              end
            end
          end
          if service_ids.size() > 0
            invalid.push("#{service_ids.join("|")}(#{resource.get_id()})")
          end
        end

        if invalid.size() > 0
          return "#{@error_message} #{invalid.join(", ")}"
        end
  
        return nil
      end

    end
  end
end