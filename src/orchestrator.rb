require "fileutils"
require './src/configuration_orchestrator'
require './src/provision/orchestrator'
require './src/install/orchestrator'
require './src/teardown/orchestrator'
require './src/summary/orchestrator'
require './src/common/logger/logger_factory'

class Orchestrator

  def initialize(
      context,
      configuration_orchestrator = nil, provision_orchestrator = nil,
      install_orchestrator = nil, teardown_orchestrator = nil,
      summary_orchestrator = nil)
    @context = context
    @configuration_orchestrator = configuration_orchestrator || ConfigurationOrchestrator.new(context)
    @provision_orchestrator = provision_orchestrator || Provision::Orchestrator.new(context)
    @install_orchestrator = install_orchestrator || Install::Orchestrator.new(context)
    @teardown_orchestrator = teardown_orchestrator || Teardown::Orchestrator.new(context)
    @summary_orchestrator = summary_orchestrator || Summary::Orchestrator.new(context)
  end

  def execute(arguments = ARGV)
    @configuration_orchestrator.execute(arguments)
    output = nil
    if is_teardown?()
      output = @teardown_orchestrator.execute()
    else
      Common::Logger::LoggerFactory.get_logger().debug("provision_orchestrator.execute()")
      @provision_orchestrator.execute()
      Common::Logger::LoggerFactory.get_logger().debug("install_orchestrator.execute()")
      @install_orchestrator.execute()
      Common::Logger::LoggerFactory.get_logger().debug("summary_orchestrator.execute()")
      output = @summary_orchestrator.execute()
    end    
    if is_delete_tmp?()
      deployment_path = get_deployment_path()
      FileUtils.remove_entry_secure(deployment_path, true)
    end
    return output
  end

  def is_teardown?()
    return @context.get_command_line_provider().is_teardown?()
  end

  def is_delete_tmp?()
    return @context.get_command_line_provider().is_delete_tmp?()
  end

  def get_execution_path()
    return @execution_path ||= @context.get_app_config_provider().get_execution_path()
  end

  def get_deployment_name()
    return @deployment_name ||= @context.get_command_line_provider().get_deployment_name()
  end

  def get_deployment_path()
    return @deployment_path ||= "#{get_execution_path()}/#{get_deployment_name()}"
  end

end
