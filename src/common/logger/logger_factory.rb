require './src/common/logger/info_logger'
require './src/common/logger/debug_logger'
require './src/common/logger/error_logger'

module Common
  module Logger
    class LoggerFactory

      def self.set_logging_level(logging_level = "error")
        @logging_level = logging_level
        @logger = nil
      end

      def self.get_logging_level()
        return @logging_level
      end

      def self.set_execution_type(execution_type)
        @execution_type = execution_type
      end

      def self.get_logger()
        return @logger ||= self.create_logger_type()
      end

      private
      def self.create_logger_type()
        case @logging_level
        when 'debug'
          return Common::Logger::DebugLogger.new()
        when 'error'
          return Common::Logger::ErrorLogger.new()
        else
          return Common::Logger::InfoLogger.new()
        end
      end

    end
  end
end