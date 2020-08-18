module Provision
  module Templates
    class TemplateContext

      def initialize(output_file_path, template_file_path, context, resource)
        @output_file_path = output_file_path
        @template_file_path = template_file_path
        @context = context
        @resource = resource
      end

      def get_execution_path()
        return get_output_file_path()
      end

      def get_output_file_path()
        return @output_file_path
      end

      def get_template_file_path()
        return @template_file_path
      end

      def get_context()
        return @context
      end

      def get_resource()
        return @resource
      end

      def get_deployment_name()
        return get_command_line_provider().get_deployment_name()
      end

      def get_resource_id()
        return get_resource().get_id()
      end

      def get_resource_name()
        return "#{get_deployment_name()}-#{get_resource_id()}"
      end

      def get_infrastructure_provider()
        return get_context().get_infrastructure_provider()
      end

      def get_command_line_provider()
        return get_context().get_command_line_provider()
      end

      def get_services_provider()
        return get_context().get_services_provider()
      end

      def get_app_config_provider()
        return get_context().get_app_config_provider()
      end

      def get_provision_provider()
        return get_context().get_provision_provider()
      end

    end
  end
end