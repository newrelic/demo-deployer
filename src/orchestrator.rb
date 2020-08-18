require './src/configuration_orchestrator'
require './src/provision/orchestrator'
require './src/install/orchestrator'
require './src/teardown/orchestrator'
require './src/summary/orchestrator'

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
    if is_teardown?()
      return @teardown_orchestrator.execute()
    else
      @provision_orchestrator.execute()
      @install_orchestrator.execute()
      return @summary_orchestrator.execute()
    end
  end

  def is_teardown?()
    return @context.get_command_line_provider().is_teardown?()
  end

end