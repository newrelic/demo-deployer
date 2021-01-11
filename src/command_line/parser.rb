require 'optparse'
require "./src/common/validation_error"

module CommandLine
  class Parser
    def initialize(context, opts = OptionParser.new())
      @context = context
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

      if options[:user_config].nil?
        options[:user_config] = find_user_config_path()
      end

      return options
    end

    private
    def create_options()
      options = {
          logging_level: "info"
      }

      @opts.banner = "Usage: config"

      @opts.on('-c', '--config USER_CONFIG', "The user credentials defaults to '#{ @context.get_app_config_provider().get_user_default_config_path() }', override as needed") do |config|
        options[:user_config] = config
      end


      @opts.on('-l', '--logging LEVEL', String, 'Logging level used during deployment or teardown. debug, info (default), error') do |logging|
        options[:logging_level] = logging
      end

      @opts.on('-d', '--deployment DEPLOY_CONFIG', 'The deployment configuration file. This can be a public URL to a json file') do |config|
        options[:deploy_config] = config
      end

      @opts.on('-t', '--teardown', FalseClass, 'Specify a teardown must be done, instead of a regular deploy') do |config|
        options[:is_teardown] = true
      end

      return options
    end

    def find_user_config_path()
      path = @context.get_app_config_provider().get_user_default_config_path()
      user_config_files = Dir.glob path

      if user_config_files.length == 0
        raise Common::ValidationError.new("No user config file found in configs directory")
      elsif user_config_files.length == 1
        return user_config_files.first
      else
        raise Common::ValidationError.new("Too many user config files found: #{ user_config_files.join(", ")}\nTo fix either remove one of the user config files or specify which config file you want to use with the '-c' command line flag")
      end
    end
  end
end