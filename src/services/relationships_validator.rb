require "json"

module Services
  class RelationshipsValidator

    def initialize(error_message = nil)
      @error_message = error_message || "Error"
    end

    def execute(services, resources)
      invalid = []

      grouped_service_ids = (services || []).group_by { |service| service['id'] }
      grouped_resource_ids = (resources || []).group_by { |resource| resource.get_id() }
      services.each do |service|
        (service['relationships'] || []).each do |relationship|
          service_exists = grouped_service_ids.key?(relationship)
          resource_exists = grouped_resource_ids.key?(relationship)

          if service_exists==false && resource_exists==false
            invalid.push(service.to_json)
          end

        end
      end

      if invalid.length>0
        return "#{@error_message} #{invalid.join(", ")}"
      end

      return nil
    end

  end
end