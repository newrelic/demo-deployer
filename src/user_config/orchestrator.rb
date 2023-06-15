require_relative "parser"
require_relative "validator"
require_relative "provider"

require "./src/common/validation_error"

module UserConfig
  class Orchestrator

    def initialize(context,
                   parser = nil,
                   validator = nil,
                   is_validation_enabled = true)
      @context = context
      @parser = parser || UserConfig::Parser.new()
      @validator = validator || UserConfig::Validator.new()
      @is_validation_enabled = is_validation_enabled
    end

    def execute(user_config_content = nil)
      log_token = Common::Logger::LoggerFactory.get_logger().add_sub_task('Validating user config')

      if user_config_content.nil?
        user_config_content = get_command_line_provider().get_user_config_content()
      end
      parsed_user_config = @parser.execute(user_config_content)
      provider = UserConfig::Provider.new(parsed_user_config)
      deployment_path = get_command_line_provider().get_deployment_path()
      provider.ensure_all_created(deployment_path)
      if @is_validation_enabled
        validation_errors = @validator.execute(parsed_user_config)
        unless validation_errors.empty?
          log_token.error()
          raise Common::ValidationError.new("User Configuration failed validation:", validation_errors)
        end
      end
      @context.set_user_config_provider(provider)
      log_token.success()
      return provider
    end
    
    private
    def get_command_line_provider()
      return @context.get_command_line_provider()
    end

  end
end
