module Common
  module Logger
    class LogTaskToken

      def initialize(registartion_handler = nil, success_handler = nil, error_handler = nil)
        @registartion_handler = registartion_handler
        @success_handler = success_handler
        @error_handler = error_handler
      end

      def register(sub_task)
        if @registartion_handler != nil
          @registartion_handler.call(sub_task)
        end
      end

      def success()
        if @success_handler != nil
          @success_handler.call()
        end
      end

      def pause()
        if @success_handler != nil
          @success_handler.call()
        end
      end

      def error()
        if @error_handler != nil
          @error_handler.call()
        end
      end

    end
  end
end