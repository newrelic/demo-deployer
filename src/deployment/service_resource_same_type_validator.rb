require 'json'

module Deployment
  class ServiceResourceSameTypeValidator

    def initialize(error_message = nil)
      @error_message = error_message || "Error"
    end

    def execute(resources, services)
      found = []

      (services || []).each do |service|
        resource_types = []

        service.get_destinations().each do |destination|
          resource = get_resource_by_id(resources || [], destination)
          unless resource.nil?
            type = resource.get_type()
            unless type.nil?
              unless resource_types.include?(type)
                resource_types.push(resource.get_type())
              end
            end
          end
        end

        if resource_types.size() > 1
          found.push("#{resource_types.join("|")} #{JSON.generate(service, { quirks_mode: true })}")
        end
      end

      if found.size() > 0
        return "#{@error_message} #{found.join(", ")}"
      end

      return nil
    end

    private

    def get_resource_by_id(resources, id)
      return resources.find { |resource| resource.match_by_id(id) }
    end

  end
end