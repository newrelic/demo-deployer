require './src/command_line/orchestrator'
require './src/app_config/orchestrator'
require './src/common/tasks/runner'
require_relative 'provider'
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
      get_modes().each do |mode|
        if is_mode_deploy?(mode)
          runner.deploy(partitions)
        end

        if is_mode_teardown?(mode)
          runner.teardown(partitions)
        end
      end

      log_token.success()
    end

    private

    def init_logging()
      logging_level = @context.get_command_line_provider().get_logging_level()
      Common::Logger::LoggerFactory.set_logging_level(logging_level)
      modes = @context.get_command_line_provider().get_modes()
      return Common::Logger::LoggerFactory.get_logger().task_start("Executing batch processing, mode:#{modes}, batchSize:#{@context.get_command_line_provider().get_batch_size()}")
    end

    def get_modes()
      return @context.get_command_line_provider().get_modes()
    end

    def is_mode_deploy?(mode)
      return @context.get_command_line_provider().is_mode_deploy?(mode)
    end

    def is_mode_teardown?(mode)
      return @context.get_command_line_provider().is_mode_teardown?(mode)
    end

    def get_runner()
      return @runner ||= Common::Tasks::Runner.new(@context)
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