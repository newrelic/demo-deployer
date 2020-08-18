require "json"

module Deployment
  module Aws
    module Lambda
      class SingleServiceValidator

        def initialize(services, error_message = nil)
          @services = services || []
          @error_message = error_message || "The following lambda resources are being referenced by more than 1 service:"
        end

        def execute(resources)
          invalid = []

          (resources || []).each do |resource|
            service_ids = []
            @services.each do |service|
              if service.get_destinations().any? { |destination| destination == resource.get_id() }
                service_ids.push(service.get_id())
              end
            end
            if service_ids.size() > 1
              invalid.push("#{service_ids.join("|")} #{JSON.generate(resource, { quirks_mode: true })}")
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
end