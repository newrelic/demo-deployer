module Service
  module CommandLine
    class Provider

      def initialize(context, options)
        @context = context
        @options = options
      end

      def get_queue_url()
        return @options[:queue_url]
      end

      def get_user_config_filepath()
        return @options[:user_config]
      end

      def get_wait_time_seconds()
        return @options[:wait_time_seconds]
      end

      def get_logging_level()
        return @options[:logging_level].downcase()
      end

    end
  end
end