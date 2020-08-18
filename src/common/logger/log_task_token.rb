module Common
  module Logger
    class LogTaskToken

      def initialize(success_handler = nil, error_handler = nil)
        @success_handler = success_handler
        @error_handler = error_handler
      end

      def success()
        if @success_handler!=nil
          @success_handler.call()
        end
      end

      def error()
        if @error_handler!=nil
          @error_handler.call()
        end
      end

    end
  end
end