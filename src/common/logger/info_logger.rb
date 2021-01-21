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
        task_handler = TTY::Spinner::Multi.new("[:spinner] #{task_name}", format: :classic, success_mark: @pastel.green('✔'), error_mark: @pastel.red('✖'), output: $stdout)
        token = LogTaskToken.new(lambda { return task_handler }, lambda { task_success(task_handler) }, lambda { task_error(task_handler) })
        @registered_spinners.push(token)
        return token
      end

      def get_sub_task
        @registered_spinners.last
      end

      def add_sub_task_top(task_name)
        add_sub_task(@registered_spinners.last, task_name)
      end

      def add_sub_task(task_parent, task_name)
        if task_parent.nil?
          return LogTaskToken.new(lambda {}, lambda {}, lambda {})
        end
        spin = task_parent.get_ref().register("[:spinner] #{task_name}")

        return LogTaskToken.new(lambda { return spin }, lambda { task_pause(spin) }, lambda { task_error(spin) })
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
        task_handler.success()
      end

      def task_pause(task_handler)
        deregister_handler(task_handler)
        task_handler.pause()
      end

      def task_error(task_handler)
        deregister_handler(task_handler)
        task_handler.error()
      end

      def deregister_handler(task_handler)
        if @registered_spinners.include?(task_handler)
          @registered_spinners.delete(task_handler)
        end
      end

    end
  end
end