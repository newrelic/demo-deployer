require "./src/common/logger/logger"
require "./src/common/logger/log_task_token"

module Common
  module Logger
    class ErrorLogger < Logger

      def error(message)
        output_message("[ERROR]", message)
      end

    end
  end
end