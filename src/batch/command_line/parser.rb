require 'optparse'

module Batch
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
            mode: "deploy",
            logging_level: "info"
        }

        @opts.banner = "Usage: config"

        @opts.on('-c', '--configpath', 'The local path for the user config file or files') do |config|
          options[:user_config] = config
        end

        @opts.on('-d', '--deploymentpath', 'The local path for the deployment config file or files.') do |config|
          options[:deploy_config] = config
        end

        @opts.on('-m', '--mode', String, 'Specify the mode for deployment: deploy (default), teardown, deployteardown') do |mode|
          options[:mode] = mode
        end

        @opts.on('-l', '--logging LEVEL', String, 'Logging level used during deployment or teardown. debug, info (default), error') do |logging|
          options[:logging_level] = logging
        end
        
        @opts.on('-i', '--ignore_teardown_error', FalseClass, 'When tearing down, specify if any error should be ignored (default false)') do |config|
          options[:ignore_teardown_error] = true
        end

        return options
      end
    end
  end
end