module Batch
  class Context

    def initialize()
      @context = {}
    end

    def set_command_line_provider(provider)
      @context[:command_line_provider] = provider
    end
  
    def get_command_line_provider()
      @context[:command_line_provider]
    end
  
    def set_app_config_provider(provider)
      @context[:app_config_provider] = provider
    end
  
    def get_app_config_provider()
      @context[:app_config_provider]
    end

  end
end