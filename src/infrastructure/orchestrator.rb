require "json"
require "./src/common/json_parser"
require_relative "validator"
require_relative "provider"

module Infrastructure
  class Orchestrator

    def initialize(context,
                   parser = nil,
                   validator = nil,
                   is_validation_enabled = true
                  )
      @context = context
      @parser = parser || Common::JsonParser.new()
      @validator = validator
      @is_validation_enabled = is_validation_enabled
    end

    def execute(deploy_config_content = nil)
      log_token = Common::Logger::LoggerFactory.get_logger().add_sub_task('Validating resources')

      command_line_provider = @context.get_command_line_provider()
      if deploy_config_content.nil?
        deploy_config_content = command_line_provider.get_deployment_config_content()
      end
      parsed_resources = @parser.get_children(deploy_config_content, "resources")
      if @is_validation_enabled
        validation_errors = get_validator().execute(parsed_resources)
        unless validation_errors.empty?
          log_token.error()
          raise Common::ValidationError.new("Infrastructure validation has failed", validation_errors)
        end
      end
      provider = Infrastructure::Provider.new(@context, parsed_resources)
      @context.set_infrastructure_provider(provider)
      log_token.success()
      return provider
    end

    private
    def get_validator()
     return @validator ||= Infrastructure::Validator.new(@context)
    end

  end
end
