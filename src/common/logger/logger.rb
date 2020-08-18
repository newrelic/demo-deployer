module Common
  module Logger
    class Logger

      def initialize() end

      def task_start(task_name) return LogTaskToken.new() end

      def info(message) end

      def debug(message) end

      def error(message) end

      private
      def task_success(task_name) end

      def task_error(task_name) end

      def output_message(label, message)
        if message.is_a? Enumerable
          puts "#{label}"
          puts message
        else
          puts "#{label} #{message}"
        end
      end
    end
  end
end