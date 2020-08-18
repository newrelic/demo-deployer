module Deployment
  class ListenersExistValidator

    def initialize(type)
      @type = type
    end

    def execute(resources, services)
      missing = []
      resources_to_search = resources.select { |resource| resource.instance_of?(@type) }

      service_ids = services.collect { |x| x.get_id() }.compact()

      unless resources_to_search.nil?
        resources_to_search.each do |resource|
          not_found_services = []
          resource.get_listeners().each do |value|
            unless service_ids.include?(value)
              not_found_services.push(value)
            end
          end
          if not_found_services.count > 0
            message = "The #{resource.get_id()} has listeners that are not valid services #{not_found_services.join('|')}"
            missing.push(message)
          end
        end
      end

      if missing.length > 0
        return missing.join(', ')
      end

      return nil
    end

  end
end