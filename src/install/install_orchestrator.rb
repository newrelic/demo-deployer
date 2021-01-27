require './src/common/io/directory_service'
require "./src/common/install/installer"
require "./src/common/logger/logger_factory"
require "./src/install/install_definitions_builder"

module Install
  class InstallOrchestrator
    def initialize(context,
                  installer = nil,
                  temporary_directory_service = nil)
      @context = context
      @installer = installer
      @temporary_directory_service = temporary_directory_service
      @execution_path = nil
    end

    def execute(provisioned_resources)
      install_definitions = []
      install_definitions.concat(execute_on_host_install(provisioned_resources))
      install_definitions.concat(execute_service_plus_instrumentation_install(provisioned_resources))
      install_definitions.concat(execute_global_instrumentation_install(provisioned_resources))
      execute_install(install_definitions, "#{install_definitions.length} Definitions")
    end

    private
    def execute_on_host_install(provisioned_resources)
      install_definitions = get_install_definitions_builder(provisioned_resources)
                                .with_onhost_instrumentations()
                                .build()
      return install_definitions
    end

    def execute_service_plus_instrumentation_install(provisioned_resources)
      install_definitions = get_install_definitions_builder(provisioned_resources)
                                .with_services()
                                .with_service_instrumentations()
                                .build()
      return install_definitions
    end

    def execute_global_instrumentation_install(provisioned_resources)
      install_definitions = get_install_definitions_builder(provisioned_resources)
                                .with_global_instrumentations()
                                .build()
      return install_definitions
    end

    def execute_install(install_definitions, target_installation)
      unless install_definitions.empty?
        @log_token = Common::Logger::LoggerFactory.get_logger().task_start("Installing #{target_installation}")
        (@installer || get_installer()).execute(install_definitions)
        @log_token.success()
      end
    end

    def get_install_definitions_builder(provisioned_resources)
      return Install::InstallDefinitionsBuilder.new(@context, provisioned_resources)
    end

    def get_installer()
      serial = true
      parallel = false
      @installer = Common::Install::Installer.new(get_temporary_directory_service())
      @installer
        .queue_step("stop", parallel)
        .queue_step("prepare", serial)
        .queue_step("upload", parallel)
        .queue_step("instrument", serial)
        .queue_step("configure", serial)
        .queue_step("onbeforestart", serial)
        .queue_step("start", parallel)
        .queue_step("onafterstart", serial)
      return @installer
    end

    def get_execution_path()
      return @execution_path ||= @context.get_app_config_provider().get_execution_path()
    end

    def get_temporary_directory_service()
      return (@temporary_directory_service ||= Common::Io::DirectoryService.new(get_execution_path()))
    end
  end
end
