module Batch
  module CommandLine
    class Provider

      def initialize(context, options)
        @context = context
        @options = options
      end

      def get_user_config_filepath()
        return @options[:user_config]
      end

      def get_deploy_config_filepath()
        return @options[:deploy_config]
      end

      def get_batch_size()
        return @options[:batch_size]
      end

      def is_mode_deploy?()
        return @options[:mode].downcase() == "deploy" || @options[:mode].downcase() == "deployteardown"
      end

      def is_mode_teardown?()
        return @options[:mode] == "teardown".downcase() || @options[:mode].downcase() == "deployteardown"
      end

      def is_ignore_teardown_errors?()
        return @options[:ignore_teardown_errors] == true
      end

      def get_logging_level()
        return @options[:logging_level].downcase()
      end

    end
  end
end