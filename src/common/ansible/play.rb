module Common
  module Ansible
    class Play
      def initialize(play_name, script_path, host_file_path, execution_path, host_exist = true, on_executed_handlers = [])
        @play_name = play_name
        @script_path = script_path
        @host_file_path = host_file_path
        @execution_path = execution_path
        @host_exist = host_exist
        @on_executed_handlers = on_executed_handlers
        @output_file_path = nil

        @log_token = Common::Logger::LoggerFactory.get_logger().add_sub_task_top(play_name)
      end

      # def get_log_token
      #   return @log_token
      # end

      def start()
        @log_token.get_ref().auto_spin()
      end

      def success()
        @log_token.success()
      end

      def error()
        @log_token.error()
      end

      def host_exist?()
        return @host_exist
      end

      def get_play_name()
        return @play_name
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