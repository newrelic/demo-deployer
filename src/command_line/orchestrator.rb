require "./src/common/validation_error"

require_relative "parser"
require_relative "validator"
require_relative "provider"

module CommandLine
  class Orchestrator

    def initialize(context,
                   parser = nil,
                   validator = nil,
                   is_validation_enabled = true)
      @context = context
      @parser = parser || CommandLine::Parser.new()
      @validator = validator || CommandLine::Validator.new()
      @is_validation_enabled = is_validation_enabled
    end

    def execute(args)
      parser_options = @parser.execute(args)
      if @is_validation_enabled
        validation_errors = @validator.execute(parser_options)
        unless validation_errors.empty?
          raise Common::ValidationError.new("Command Line validation has failed", validation_errors)
        end
      end
      provider = CommandLine::Provider.new(@context, parser_options)
      @context.set_command_line_provider(provider)
      return provider
    end

  end
end
