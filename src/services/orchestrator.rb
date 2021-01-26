require "./src/common/validation_error"
require "./src/common/io/git_proxy"
require "./src/common/io/directory_copier"

require "./src/common/json_parser"
require_relative "validator"
require_relative "provider"
require "./src/common/logger/logger_factory"

module Services
  class Orchestrator

    def initialize(context,
                   parser = nil,
                   validator = nil,
                   git_proxy = nil,
                   directory_copier = nil,
                   is_validation_enabled = true)
      @context = context
      @parser = parser
      @validator = validator
      @git_proxy = git_proxy
      @directory_copier = directory_copier
      @is_validation_enabled = is_validation_enabled
    end

    def execute(deploy_config_content = nil)
      log_token = Common::Logger::LoggerFactory.get_logger().add_sub_task('Validating services')

      command_line_provider = @context.get_command_line_provider()
      deployment_name = command_line_provider.get_deployment_name()

      tags_provider = @context.get_tags_provider()

      app_config_provider = @context.get_app_config_provider()
      execution_path = app_config_provider.get_execution_path()

      infrastructure_provider = @context.get_infrastructure_provider()
      resources = infrastructure_provider.get_all()

      if deploy_config_content.nil?
        deploy_config_content = command_line_provider.get_deployment_config_content()
      end
      services = get_parser().get_children(deploy_config_content, "services")
      if @is_validation_enabled
        validation_errors = get_validator().execute(services, resources, app_config_provider)
        unless validation_errors.empty?
          log_token.error()
          raise Common::ValidationError.new("Service definition validation has failed", validation_errors)
        end
      end

      source_paths_file = get_source_paths_file(services, execution_path, deployment_name)
      provider = Services::Provider.new(services, source_paths_file, tags_provider)
      @context.set_services_provider(provider)
      log_token.success()
      return provider
    end

    private

    def get_source_paths_file(services, execution_path, deployment_name)
      file = {}
      services.each do |service|
        service_id = service["id"]
        destination_path = "#{execution_path}/#{deployment_name}/#{service_id}"

        if service["local_source_path"]
          local_source_path = service["local_source_path"]
          full_source_path = get_directory_copier().copy(local_source_path, destination_path)
          file[service_id] = full_source_path
        else
          source_repository = service["source_repository"]
          cloned_source_path = get_git_proxy().clone(source_repository, destination_path)
          file[service_id] = cloned_source_path
        end
      end
      return file
    end

    def get_parser()
      return @parser ||= Common::JsonParser.new()
    end

    def get_validator()
      return @validator ||= Services::Validator.new(@context)
    end

    def get_git_proxy()
      return @git_proxy ||= Common::Io::GitProxy.new(@context)
    end

    def get_directory_copier()
      return @directory_copier ||= Common::Io::DirectoryCopier.new()
    end

  end
end