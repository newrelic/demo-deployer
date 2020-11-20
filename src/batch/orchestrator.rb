require './src/command_line/orchestrator'
require './src/app_config/orchestrator'
require_relative 'command_line/parser'
require_relative 'command_line/provider'
require_relative 'command_line/validator'

module Batch
  class Orchestrator

    def initialize(
        context,
        command_line_orchestrator = nil,
        app_config_orchestrator = nil
        )
      @context = context
      @command_line_orchestrator = command_line_orchestrator
      @app_config_orchestrator = app_config_orchestrator
    end

    def execute(arguments = ARGV)
      get_command_line_orchestrator().execute(arguments)
      get_app_config_orchestrator().execute()
      log_token = init_logging()

      log_token.success()
    end

    private

    def init_logging()
      logging_level = @context.get_command_line_provider().get_logging_level()
      Common::Logger::LoggerFactory.set_logging_level(logging_level)
      displayMode = ""
      if @context.get_command_line_provider().is_mode_deploy?()
        displayMode = "#{displayMode} Deploy"
      end
      if @context.get_command_line_provider().is_mode_teardown?()
        displayMode = "#{displayMode} Teardown"
        if @context.get_command_line_provider().is_ignore_teardown_errors?()
          displayMode = "(ignore errors)"
        end
      end
      Common::Logger::LoggerFactory.get_logger().info("Executing batch processing, mode:#{displayMode}, batchSize:#{@context.get_command_line_provider().get_batch_size()}")
      Common::Logger::LoggerFactory.get_logger().task_start("Parsing and validating configuration")
    end

    def get_app_config_orchestrator()
      return @app_config_orchestrator ||= AppConfig::Orchestrator.new(@context)
    end

    def get_command_line_orchestrator()
      return @command_line_orchestrator ||= ::CommandLine::Orchestrator.new(@context,
          Batch::CommandLine::Parser.new(),
          Batch::CommandLine::Validator.new(),
          Batch::CommandLine::Provider)
    end

  end
end