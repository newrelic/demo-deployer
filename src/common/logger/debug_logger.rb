require "./src/common/logger/logger"
require "./src/common/logger/log_task_token"

module Common
  module Logger
    class DebugLogger < Logger

      def task_start(task_name)
        puts "Task '#{task_name}': - Started"
        return LogTaskToken.new(lambda { return task_success(task_name)}, lambda { return task_error(task_name)})
      end

      def debug(message)
        output_message("[DEBUG]", message)
      end

      def info(message)
        output_message("[INFO]", message)
      end

      def error(message)
        output_message("[ERROR]", message)
      end

      private
      def task_success(task_name)
        puts "Task '#{task_name}': - Success"
      end

      def task_error(task_name)
        puts "Task '#{task_name}': - Failure"
      end

    end
  end
end