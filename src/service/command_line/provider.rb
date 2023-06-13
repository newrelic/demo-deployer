module Service
  module CommandLine
    class Provider

      def initialize(context, options)
        @context = context
        @options = options
        @config_loader_lambda = lambda { |filepath| return get_file_content(filepath) }
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

      def get_batch_size()
        return @options[:batch_size]
      end

      def get_logging_level()
        return @options[:logging_level].downcase()
      end

      def get_notification_table_name()
        return @options[:notification_table_name]
      end

      def is_teardown?()
        return @options[:is_teardown] == true
      end

      def get_user_config_name()
        filepath = get_user_config_filepath()
        config_name = strip_to_name(filepath)
        return config_name
      end

      def get_user_config_content()
        filepath = @options[:user_config]
        @user_file_content ||= @config_loader_lambda.call(filepath)
        return @user_file_content
      end

      def get_file_content(input)
        unless input.nil?
          filepath = input
          if is_url?(input)
            filepath = get_local_path_for_remote(input)
            download_file(input, filepath)
          end
          return File.read(filepath)
        end
        return nil
      end

      def is_url?(input)
        if input!=nil && input.downcase().start_with?("http")
          return true
        end
        return false
      end
  
    end
  end
end