require "./src/common/validation_error"

require_relative "parser"
require_relative "validator"
require_relative "provider"

module Tags
  class Orchestrator

    def initialize(context,
                   parser = Tags::Parser.new(),
                   validator = Tags::Validator.new())
      @context = context
      @parser = parser
      @validator = validator
    end

    def execute(deploy_config_content = nil)
      log_token = Common::Logger::LoggerFactory.get_logger().add_sub_task('Validating tags')

      command_line_provider = @context.get_command_line_provider()
      if deploy_config_content.nil?
        deploy_config_content = command_line_provider.get_deployment_config_content()
      end

      parsed_output = @parser.execute(deploy_config_content)
      global_tags = parsed_output.get_global_tags()
      validation_errors = @validator.execute(global_tags)
      unless validation_errors.empty?
        log_token.error()
        raise Common::ValidationError.new("Global tags failed validation: ", validation_errors)
      end

      services_tags = parsed_output.get_services_tags()
      services_tags.each do |service_id, service_tags|
        validation_errors = @validator.execute(service_tags)
        unless validation_errors.empty?
          raise Common::ValidationError.new("Service tags failed validation for service id '#{service_id}': ", validation_errors)
          log_token.error()
        end
      end

      resources_tags = parsed_output.get_resources_tags()
      resources_tags.each do |resource_id, resource_tags|
        validation_errors = @validator.execute(resource_tags)
        unless validation_errors.empty?
          raise Common::ValidationError.new("Resource tags failed validation for resource id '#{resource_id}': ", validation_errors)
          log_token.error()
        end
      end

      provider = Tags::Provider.new(@context, global_tags, services_tags, resources_tags)
      @context.set_tags_provider(provider)
      log_token.success()
      return provider
    end

  end
end