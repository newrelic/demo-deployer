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
            batch_size: 10,
            logging_level: "info"
        }

        @opts.banner = "Usage: config"

        @opts.on('-c', '--configpath FILEPATH', 'The local path for the user config file or files. This can be a comma separated list of files or folders.') do |config|
          options[:user_config] = config
        end

        @opts.on('-d', '--deployment FILEPATH', 'The local path for the deployment config file or files. This can be a comma separated list of files or folders.') do |config|
          options[:deploy_config] = config
        end

        @opts.on('-s', '--batch_size integer', Integer, 'Specify how many concurrent deployments to process at once, default to 10') do |value|
          options[:batch_size] = value
        end

        @opts.on('-m', '--mode deploy/teardown/deployteardown', String, 'Specify the mode for deployment: deploy (default), teardown, deployteardown') do |mode|
          options[:mode] = mode
        end

        @opts.on('-l', '--logging level', String, 'Logging level used during deployment or teardown. debug, info (default), error') do |logging|
          options[:logging_level] = logging
        end

        @opts.on('-i', '--ignore_teardown_errors', FalseClass, 'When tearing down, specify if any error should be ignored (default false)') do |config|
          options[:ignore_teardown_errors] = true
        end

        return options
      end
    end
  end
end