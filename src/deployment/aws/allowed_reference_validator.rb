module Deployment
  module Aws
    class AllowedReferenceValidator

      def initialize(resource_type, allowed_reference_resource_type, context, error_message = nil)
        @resource_type = resource_type
        @allowed_reference_resource_type = allowed_reference_resource_type
        @context = context
        @error_message = error_message || "The following resource(s) have an invalid resource type as reference_id, only types:#{@allowed_reference_resource_type.join(',')} are accepted:"
      end

      def execute(resources = [])
        invalid = []

        resources_to_search = resources.select {|resource| resource.instance_of?(@resource_type) }
        (resources_to_search || []).each do |resource|
          reference_id = resource.get_reference_id()
          unless reference_id.nil?
            reference_resource = get_infrastructure_provider().get_by_id(reference_id)
            unless reference_resource.nil?
              if @allowed_reference_resource_type.all? { |resource_type| resource_type != reference_resource.get_type() }
                invalid.push("#{reference_id}/#{reference_resource.get_type()}")
              end
            end
          end
        end

        if invalid.length > 0
          return " #{@error_message} #{invalid.join(', ')} "
        end

        return nil
      end

      def get_infrastructure_provider()
        return @context.get_infrastructure_provider()
      end

    end
  end
end