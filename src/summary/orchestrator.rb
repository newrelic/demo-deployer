require './src/common/validation_error'
require './src/summary/composer'
require './src/common/io/file_writer'
require './src/common/logger/logger_factory'

module Summary
  class Orchestrator

    def initialize(context)
      @context = context
      @summary_composer = Summary::Composer.new()
      @summary_file_path = nil
    end

    def execute()
      summary = get_results()
      write_console_message(summary)
      write_summary_file(summary)
      return summary
    end

    private

    def get_results()
      instrumentation_provider = @context.get_instrumentation_provider()

      provisioned_resources = @context.get_install_provider().get_all()
      installed_services = @context.get_provision_provider().get_all()
      resource_instrumentors = instrumentation_provider.get_all_resource_instrumentors()
      service_instrumentors = instrumentation_provider.get_all_service_instrumentors()
      global_intrumentors = instrumentation_provider.get_all_global_instrumentors() 

      composer_result = @summary_composer.execute(provisioned_resources, installed_services, resource_instrumentors, service_instrumentors, global_intrumentors)

      summary = "Deployment successful!\n\n"
      summary += "#{composer_result}"
      return summary
    end

    def write_console_message(summary)
      Common::Logger::LoggerFactory.get_logger.info("#{summary}")
      Common::Logger::LoggerFactory.get_logger.info("This deployment summary can also be found in:\n")
      Common::Logger::LoggerFactory.get_logger.info("  #{get_summary_file_path()}\n\n")
      return nil
    end

    def write_summary_file(summary)
      full_path = get_summary_file_path()
      file_writer = Common::Io::FileWriter.new(full_path, summary)
      file_writer.execute()
      return nil
    end

    def get_summary_file_path()
      return @summary_file_path ||= create_summary_file_path()
    end

    def create_summary_file_path()
      app_config_provider = @context.get_app_config_provider()
      execution_path = app_config_provider.get_execution_path()
      filename = app_config_provider.get_summary_filename()
      command_line_provider = @context.get_command_line_provider()
      deployment_name = command_line_provider.get_deployment_name()
      return "#{execution_path}/#{deployment_name}/#{filename}"
    end

  end
end
