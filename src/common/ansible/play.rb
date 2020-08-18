module Common
  module Ansible
    class Play
      def initialize(script_path, host_file_path, execution_path, host_exist = true, on_executed_handlers = [])
        @script_path = script_path
        @host_file_path = host_file_path
        @execution_path = execution_path
        @host_exist = host_exist
        @on_executed_handlers = on_executed_handlers
        @output_file_path = nil
      end

      def host_exist?()
        return @host_exist
      end

      def get_script_path()
        return @script_path
      end

      def get_host_file_path()
        return @host_file_path
      end

      def get_execution_path()
        return @execution_path
      end

      def get_output_file_path()
        return @output_file_path
      end

      def get_on_executed_handlers()
        return @on_executed_handlers
      end

      def set_output_file_path(value)
        @output_file_path = value
      end

    end
  end
end