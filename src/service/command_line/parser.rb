require 'optparse'

module Service
  module CommandLine
    class Parser
      def initialize(opts = OptionParser.new())
        @opts = opts
      end

      def execute(command_line_arguments)
        if command_line_arguments.length == 0
          command_line_arguments.push("-h")
        end
  
        options = create_options()
  
        begin
          @opts.parse(command_line_arguments)
        rescue OptionParser::InvalidOption, OptionParser::MissingArgument => e
          raise "Command Line Parsing Error: #{e}"
        end
  
        return options
      end

      private
      def create_options()
        options = {
            wait_time_seconds: 10,
            batch_size: 10,
            logging_level: "info",
            notification_table_name: "",
        }

        @opts.banner = "Usage: config"

        @opts.on('-q', '--queue URL', String, 'The URL of the Amazon SQS queue from which messages are received.') do |config|
          options[:queue_url] = config
        end

        @opts.on('-w', '--wait-time-seconds integer', Integer, 'The duration (in seconds) for which the call waits for a message to arrive in the queue before returning. If a message is available, the call returns sooner. Default is 10s.') do |config|
          options[:wait_time_seconds] = config
        end

        @opts.on('-n', '--notification_table_name NAME', String, 'The name of the DynamoDB table to write the response to.') do |config|
          options[:notification_table_name] = config
        end

        @opts.on('-c', '--configpath FILEPATH', 'The local path for the user config file or files. This can be a comma separated list of files or folders.') do |config|
          options[:user_config] = config
        end

        @opts.on('-l', '--logging level', String, 'Logging level used during deployment or teardown. debug, info (default), error') do |logging|
          options[:logging_level] = logging
        end

        @opts.on('-s', '--batch_size integer', Integer, 'Specify how many concurrent listeners and deployers to instantiate, default to 10') do |value|
          options[:batch_size] = value
        end

        return options
      end

    end
  end
end