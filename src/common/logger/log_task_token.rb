module Common
  module Logger
    class LogTaskToken

      def initialize(get_ref_handler = nil, success_handler = nil, error_handler = nil)
        @get_ref_handler = get_ref_handler
        @success_handler = success_handler
        @error_handler = error_handler
      end

      def get_ref()
        if @get_ref_handler != nil
          @get_ref_handler.call()
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