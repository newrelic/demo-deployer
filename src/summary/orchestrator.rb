require './src/common/validation_error'
require './src/summary/composer'
require './src/summary/json_composer'
require './src/common/io/file_writer'
require './src/common/logger/logger_factory'
require './src/common/json_parser'
require './src/install/service_field_merger_builder'

module Summary
  class Orchestrator
    def initialize(context)
      @context = context
      @summary_composer = Summary::Composer.new()
      @json_composer = Summary::JSONComposer.new()
      @summary_file_path = nil
      @json = Common::JsonParser.new
    end

    def execute()
      summary = get_results()
      summary_file_path = create_summary_file_path()
      write_console_message(summary)
      write_summary_file(summary_file_path, summary)

      json_file_path = create_summary_file_path_json()
      unless json_file_path.nil?
        json_summary = get_results_json()
        write_summary_file(json_file_path, json_summary)
      end

      if @context.get_command_line_provider().is_output_ini?()
        ini_summary = get_results_ini()
        ini_filename = @context.get_app_config_provider.get_summary_ini_filename()
        ini_file_path = File.absolute_path(ini_filename)
        write_summary_file(ini_file_path, ini_summary)
      end

      return summary
    end

    private

    def get_results()
      provisioned_resources = @context.get_provision_provider().get_all()
      installed_services = @context.get_install_provider().get_all()

      instrumentation_provider = @context.get_instrumentation_provider()
      resource_instrumentors = instrumentation_provider.get_all_resource_instrumentors()
      service_instrumentors = instrumentation_provider.get_all_service_instrumentors()
      global_intrumentors = instrumentation_provider.get_all_global_instrumentors()

      composer_result = @summary_composer.execute(provisioned_resources, installed_services, resource_instrumentors, service_instrumentors, global_intrumentors)

      summary = "Deployment successful!\n\n"
      summary += "#{composer_result}"
      summary += "#{get_footnote}"
      return summary
    end

    def get_results_json()
      provisioned_resources = @context.get_provision_provider().get_all()
      installed_services = @context.get_install_provider().get_all()

      instrumentation_provider = @context.get_instrumentation_provider()
      resource_instrumentors = instrumentation_provider.get_all_resource_instrumentors()
      service_instrumentors = instrumentation_provider.get_all_service_instrumentors()
      global_intrumentors = instrumentation_provider.get_all_global_instrumentors()

      json_composer_results = @json_composer.execute(provisioned_resources, installed_services, resource_instrumentors, service_instrumentors, global_intrumentors)

      return json_composer_results
    end

    def get_results_ini()
      provisioned_resources = @context.get_provision_provider().get_all()
      ini_results = @summary_composer.compose_resources(provisioned_resources)
      return ini_results
    end

    def write_console_message(summary)
      Common::Logger::LoggerFactory.get_logger.info("#{summary}")
      Common::Logger::LoggerFactory.get_logger.info("This deployment summary can also be found in:\n")
      Common::Logger::LoggerFactory.get_logger.info("  #{get_summary_file_path()}\n\n")
      return nil
    end

    def write_summary_file(file_path, summary)
      file_writer = Common::Io::FileWriter.new(file_path, summary)
      file_writer.execute()
      return nil
    end

    def write_json_summary_file(summary)
      full_path = create_summary_file_path_json()
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

    def create_summary_file_path_json()
      command_line_provider = @context.get_command_line_provider()
      output_file_path = command_line_provider.get_output_file_path()
      if output_file_path.nil?
        return nil
      end
      return File.absolute_path(output_file_path)
    end

    def get_footnote()
      deploy_config = @context.get_command_line_provider.get_deployment_config
      raw_footnote = deploy_config.fetch('output', {})['footnote']
      string_footnote = convert_to_string(raw_footnote)
      merged_footnote = get_field_merger.merge(string_footnote)

      return merged_footnote
    end

    def convert_to_string(raw_footnote)
      if raw_footnote.is_a?(String)
        return raw_footnote
      elsif raw_footnote.is_a?(Array)
        raw_footnote.push("")
        return raw_footnote.join("\n")
      end
    end

    def get_field_merger()
      services = @context.get_services_provider().get_services()
      provisioned_resources = @context.get_provision_provider().get_all()
      field_merger = Install::ServiceFieldMergerBuilder.new
        .with_services(services, provisioned_resources)
        .with_user_credentials(@context)
        .with_app_config(@context)
        .build()

      return field_merger
    end
  end
end
