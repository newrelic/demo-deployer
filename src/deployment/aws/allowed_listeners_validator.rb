module Deployment
  module Aws
    class AllowedListenersValidator

      def initialize(resource_type, services, context, error_message = nil)
        @resource_type = resource_type
        @services = services
        @context = context
        @allowed_resource_type = ["ec2"]
        @error_message = error_message || "The following resource(s) have invalid services as listeners, only types:#{@allowed_resource_type.join(',')} are accepted:"
      end

      def execute(resources = [])
        invalid_listeners = []
        invalid_services = []

        resources_to_search = resources.select {|resource| resource.instance_of?(@resource_type) }
        (resources_to_search || []).each do |resource|
          resource.get_listeners().each do |listener|
            services_matched = @services.select { |service| service.get_id() == listener }
            services_matched.each do |service_matched|
              service_matched.get_destinations().each do |destination|
                all_resources = get_infrastructure_provider().get_all()

                invalid = validate_if_destinations_allowed_type(all_resources, destination)
                if invalid.size > 0
                  invalid_services.push(service_matched.get_id())
                end
              end
            end

          end
          if invalid_services.size > 0
            invalid_listeners.push("#{resource.get_id()}[#{invalid_services.join("|")}]")
          end
        end

        if invalid_listeners.length > 0
          return " #{@error_message} #{invalid_listeners.join(', ')} "
        end

        return nil
      end

      private

      def validate_if_destinations_allowed_type(resources, service_destination)
        invalid = []
        resource_destination_matches = resources.select { |resource| resource.get_id()== service_destination }
        resource_destination_matches.each do |destination|
          if @allowed_resource_type.all? { |resource_type| resource_type != destination.get_type() }
            invalid.push(destination)
          end
          return invalid
        end
      end

      def get_infrastructure_provider()
        return @context.get_infrastructure_provider()
      end

    end
  end
end