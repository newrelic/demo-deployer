require "./src/common/logger/logger_factory"
require "./src/install/install_orchestrator"
require "./src/install/provider"
require "./src/install/packager"

module Install
  class Orchestrator
    def initialize(context,
                  install_provider = nil,
                  packager = nil,
                  install_orchestrator = nil)
      @context = context
      @install_provider = install_provider
      @packager = packager
      @install_orchestrator = install_orchestrator
      @execution_path = nil
    end

    def execute()
      provisioned_resources = get_resources_target()
      Common::Logger::LoggerFactory.get_logger().debug("Installing on #{provisioned_resources.length} resources")
      get_packager().execute()

      get_install_orchestrator().execute(provisioned_resources)

      provider = get_install_provider()
      @context.set_install_provider(provider)
      return provider
    end

    private

    def get_resources_target()
      resources = @context.get_provision_provider().get_all()
      provisioned_resources = resources.find_all {|item| item.is_provisioned?()}
      return provisioned_resources
    end

    def get_install_provider()
      return @install_provider ||= Install::Provider.new(@context)
    end

    def get_packager()
      execution_path = get_execution_path()
      return @packager ||= Install::Packager.new(@context, execution_path)
    end

    def get_execution_path()
      return @execution_path ||= @context.get_app_config_provider().get_execution_path()
    end

    def get_install_orchestrator()
      return @install_orchestrator ||= Install::InstallOrchestrator.new(@context)
    end

  end
end
