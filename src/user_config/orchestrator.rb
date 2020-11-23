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
      if user_config_content.nil?
        command_line_provider = @context.get_command_line_provider()
        user_config_content = command_line_provider.get_user_config_content()
      end
      parsed_user_config = @parser.execute(user_config_content)
      if @is_validation_enabled
        validation_errors = @validator.execute(parsed_user_config)
        unless validation_errors.empty?
          raise Common::ValidationError.new("User Configuration failed validation:", validation_errors)
        end
      end
      provider = UserConfig::Provider.new(parsed_user_config)
      @context.set_user_config_provider(provider)
      return provider
    end
    
  end
end
