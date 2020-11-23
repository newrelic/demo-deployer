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

      def is_mode_deploy?(mode)
        return mode != nil && mode.downcase() == "deploy"
      end

      def is_mode_teardown?(mode)
        return mode != nil && mode.downcase() == "teardown"
      end

      def get_modes()
        modes = split_or_input(@options[:mode].downcase(), ',')
        return modes
      end

      def is_ignore_teardown_errors?()
        return @options[:ignore_teardown_errors] == true
      end

      def get_logging_level()
        return @options[:logging_level].downcase()
      end

      def split_or_input(input, delimiter)
        unless input.nil? 
          if input.include?(delimiter)
            return input.split(delimiter)
          end
          return [input]
        end
        return []
      end

    end
  end
end