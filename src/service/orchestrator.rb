require './src/command_line/orchestrator'
require './src/app_config/orchestrator'
require './src/common/tasks/runner'

require_relative 'deployment_repository'
require_relative 'notifier'
require_relative 'command_line/parser'
require_relative 'command_line/provider'
require_relative 'command_line/validator'

module Service
  class Orchestrator

    def initialize(
        context,
        command_line_orchestrator = nil,
        app_config_orchestrator = nil,
        deployment_repository = nil,
        notifier = nil,
        runner = nil
        )
      @context = context
      @command_line_orchestrator = command_line_orchestrator
      @app_config_orchestrator = app_config_orchestrator
      @deployment_repository = deployment_repository
      @notifier = notifier
      @runner = runner
    end

    def execute(arguments = ARGV)
      get_command_line_orchestrator().execute(arguments)
      get_app_config_orchestrator().execute()
      log_token = init_logging()

      Common::Logger::LoggerFactory.get_logger().info("Service starting with queue:#{@context.get_command_line_provider().get_queue_url()} wait_time_seconds:#{@context.get_command_line_provider().get_wait_time_seconds()}")

      while true
        Common::Logger::LoggerFactory.get_logger().info("waiting next")
        deployment = get_deployment_repository().wait_next()
        Common::Logger::LoggerFactory.get_logger().info("Receive deployment request:#{deployment}")
        partition = Common::Definitions::Partition.new(1,1)
        partition.add_deployment(deployment)
        errors = get_runner().single_deploy(partition)
        noError = errors.empty?
        Common::Logger::LoggerFactory.get_logger().info("deployment completed errors:#{errors}")
        get_notifier().execute(deployment, (noError ? 0 : 1))
        Common::Logger::LoggerFactory.get_logger().info("notification completed")
        get_runner().single_teardown(partition)
        Common::Logger::LoggerFactory.get_logger().info("teardown completed")
        sleep 1
      end

      Common::Logger::LoggerFactory.get_logger().info("Service terminating")

      log_token.success()
    end

    private

    def init_logging()
      logging_level = @context.get_command_line_provider().get_logging_level()
      Common::Logger::LoggerFactory.set_logging_level(logging_level)
      return Common::Logger::LoggerFactory.get_logger().task_start("Executing service processing")
    end

    def get_app_config_orchestrator()
      return @app_config_orchestrator ||= AppConfig::Orchestrator.new(@context)
    end

    def get_command_line_orchestrator()
      return @command_line_orchestrator ||= ::CommandLine::Orchestrator.new(@context,
          Service::CommandLine::Parser.new(),
          Service::CommandLine::Validator.new(),
          Service::CommandLine::Provider)
    end

    def get_deployment_repository()
      @deployment_repository ||= Service::DeploymentRepository.new(@context)
      return @deployment_repository
    end

    def get_notifier()
      return @notifier ||= Notifier.new(@context)
    end

    def get_runner()
      return @runner ||= Common::Tasks::Runner.new(@context)
    end

  end
end