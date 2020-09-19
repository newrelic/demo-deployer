require "./src/common/io/git_proxy"
require "./src/instrumentation/validator"
require "./src/instrumentation/provider"
require "./src/common/json_parser"
require "./src/common/validation_error"

module Instrumentation
  class Orchestrator

    def initialize(context,
        parser = nil,
        validator = nil,
        git_proxy = nil,
        is_validation_enabled = true
        )
      @context = context
      @parser = parser
      @validator = validator
      @git_proxy = git_proxy
      @is_validation_enabled = is_validation_enabled
    end

    def execute(deploy_config_content = nil)
      app_config_provider = @context.get_app_config_provider()
      execution_path = app_config_provider.get_execution_path()
      command_line_provider = @context.get_command_line_provider()
      deployment_name = command_line_provider.get_deployment_name()
      resources = @context.get_infrastructure_provider().get_all()
      resource_ids = @context.get_infrastructure_provider().get_all_resource_ids()
      services = @context.get_services_provider().get_all()
      service_ids = @context.get_services_provider().get_all_service_ids()
      
      if deploy_config_content.nil?
        deploy_config_content = command_line_provider.get_deployment_config_content()
      end
      parsed_instrumentors = get_parser().get(deploy_config_content, "instrumentations") || {}

      if @is_validation_enabled
        validation_errors = get_validator().execute(parsed_instrumentors, resource_ids, service_ids)
        unless validation_errors.empty?
          raise Common::ValidationError.new("Instrumentation validation has failed", validation_errors)
        end
      end

      destination_path = "#{execution_path}/#{deployment_name}"

      git_proxy = get_git_proxy()
      provider = Instrumentation::Provider.new(@context, parsed_instrumentors, destination_path, resources, services, git_proxy)
      @context.set_instrumentation_provider(provider)
      return provider
    end

    private

    def get_parser()
      return @parser ||= Common::JsonParser.new()
    end

    def get_validator()
      return @validator ||= Instrumentation::Validator.new(@context)
    end
    
    def get_git_proxy()
      return @git_proxy ||= Common::Io::GitProxy.new(@context)
    end

  end
end
