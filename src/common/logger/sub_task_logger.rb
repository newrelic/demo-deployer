require "tty-spinner"
require "pastel"
require "./src/common/logger/logger"
require "./src/common/logger/log_task_token"

module Common
  module Logger
    class SubTaskLogger < Logger

      def initialize(task_parent_token)
        @task_parent_token = task_parent_token
        @pastel = Pastel.new()
      end

      def task_start(task_name)
        if @task_parent_token.nil?
          return LogTaskToken.new(lambda {}, lambda {}, lambda {})
        end
        spin = @task_parent_token.register("[:spinner] #{task_name}")
        spin.auto_spin
        return LogTaskToken.new(lambda {},
                                lambda { task_pause(spin) },
                                lambda { task_error(spin) })
      end

      def info(message)
        output_message("[INFO]", message)
      end

      def error(message)
        output_message("[ERROR]", message)
      end

      private
      def task_register(task_handler)
        task_handler.register()
      end

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
      end

    end
  end
end