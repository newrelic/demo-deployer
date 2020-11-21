require './src/command_line/orchestrator'
require './src/app_config/orchestrator'
require_relative 'provider'
require_relative 'runner'
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

      provider = Provider.new(@context)
      @context.set_batch_provider(provider)

      partitions = provider.get_all_partitions()
      Common::Logger::LoggerFactory.get_logger().info("Got #{provider.get_all_deployments().length} deployments to process on #{partitions.length} partitions.")
      partitions.each do |partition|
        Common::Logger::LoggerFactory.get_logger().debug("#{partition}")
      end

      runner = get_runner()
      if is_mode_deploy?()
        partitions.each do |partition|
          log_token = Common::Logger::LoggerFactory.get_logger().task_start("Deploying:#{partition}")
          runner.deploy(partition)
          log_token.success()
        end
      end

      if is_mode_teardown?()
        partitions.each do |partition|
          ignore_error_message = ""
          if is_ignore_teardown_errors?()
            ignore_error_message = " (ignore any errors)"
          end
          log_token = Common::Logger::LoggerFactory.get_logger().task_start("Tearing down:#{partition}#{ignore_error_message}")
          runner.teardown(partition)
          log_token.success()
        end
      end

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
      return Common::Logger::LoggerFactory.get_logger().task_start("Executing batch processing, mode:#{displayMode}, batchSize:#{@context.get_command_line_provider().get_batch_size()}")
    end

    def is_mode_deploy?()
      return @context.get_command_line_provider().is_mode_deploy?()
    end

    def is_mode_teardown?()
      return @context.get_command_line_provider().is_mode_teardown?()
    end

    def is_ignore_teardown_errors?()
      return @context.get_command_line_provider().is_ignore_teardown_errors?()
    end

    def get_runner()
      return @runner ||= Runner.new(@context)
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