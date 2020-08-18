require "tty-spinner"
require "pastel"
require "./src/common/logger/logger"
require "./src/common/logger/log_task_token"

module Common
  module Logger
    class InfoLogger < Logger

      def initialize()
        @pastel = Pastel.new()
        @registered_spinners = []
      end

      def task_start(task_name)
        task_handler = TTY::Spinner.new("[:spinner] #{task_name}", format: :classic, success_mark: @pastel.green('✔'), error_mark: @pastel.red('✖'), output: $stdout)
        task_handler.auto_spin()
        @registered_spinners.push(task_handler)
        return LogTaskToken.new( lambda { task_success(task_handler)}, lambda { task_error(task_handler)})
      end

      def info(message)
        output_message("[INFO]", message)
      end

      def error(message)
        output_message("[ERROR]", message)
      end

      private
      def task_success(task_handler)
        deregister_handler(task_handler)
        task_handler.success(@pastel.green("success"))
      end

      def task_error(task_handler)
        deregister_handler(task_handler)
        task_handler.error(@pastel.red("error"))
      end

      def deregister_handler(task_handler)
        if @registered_spinners.include?(task_handler)
          @registered_spinners.delete(task_handler)
        end
      end

    end
  end
end