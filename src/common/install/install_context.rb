module Common
  module Install
    class InstallContext

      def initialize(template_output_path, template_context, host_template_context, output_params = nil)
        @template_output_path = template_output_path
        @template_context = template_context
        @host_template_context = host_template_context
        @output_params = output_params
      end

      def get_host_file_path()
        return @host_template_context.get_template_output_file_path()
      end

      def get_host_id()
        return @host_template_context.get_id()
      end

      def host_exist?()
        return @host_template_context.host_exist?()
      end

      def get_execution_path()
        return @template_context.get_execution_path()
      end

      def get_install_script_path()
        return @template_context.get_template_output_file_path()
      end

      def get_template_execution_path()
        return @template_output_path
      end

      def get_output_params()
        return @output_params
      end

    end
  end
end