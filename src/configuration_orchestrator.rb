require './src/command_line/orchestrator'
require './src/app_config/orchestrator'
require './src/infrastructure/orchestrator'
require './src/instrumentation/orchestrator'
require './src/user_config/orchestrator'
require './src/tags/orchestrator'
require './src/services/orchestrator'
require './src/deployment/orchestrator'
require './src/common/io/directory_service'
require './src/common/logger/logger_factory'

class ConfigurationOrchestrator

  def initialize(context)
    @context = context
    @command_line_orchestrator = CommandLine::Orchestrator.new(context)
    @tags_orchestrator = Tags::Orchestrator.new(context)
    @app_config_orchestrator = AppConfig::Orchestrator.new(context)
    @user_config_orchestrator = UserConfig::Orchestrator.new(context)
    @infrastructure_orchestrator = Infrastructure::Orchestrator.new(context)
    @instrumentation_orchestrator = Instrumentation::Orchestrator.new(context)
    @services_orchestrator = Services::Orchestrator.new(context)
    @deployment_orchestrator = Deployment::Orchestrator.new(context)
  end

  def execute(arguments)
    @app_config_orchestrator.execute()

    @command_line_orchestrator.execute(arguments)
    log_token = init_logging()

    create_deployment_directory()

    @user_config_orchestrator.execute()

    @tags_orchestrator.execute()
    @infrastructure_orchestrator.execute()
    @services_orchestrator.execute()
    @instrumentation_orchestrator.execute()
    @deployment_orchestrator.execute()
    log_token.success()
  end

  def create_deployment_directory()
    execution_path = @context.get_app_config_provider().get_execution_path()
    deployment_name = @context.get_command_line_provider().get_deployment_name()
    directory_service = Common::Io::DirectoryService.new(execution_path)
    directory_service.create_sub_directory(deployment_name, true)
    return nil
  end

  private
  def init_logging()
    logging_level = @context.get_command_line_provider().get_logging_level()
    Common::Logger::LoggerFactory.set_logging_level(logging_level)

    if @context.get_command_line_provider().is_teardown?()
      execution_type = "Teardown"
    else
      execution_type = "Deployment"
    end
    Common::Logger::LoggerFactory.get_logger().info("Executing #{execution_type}")
    Common::Logger::LoggerFactory.get_logger().task_start("Parsing and validating #{execution_type} configuration")
  end

end