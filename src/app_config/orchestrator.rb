require "./src/common/validation_error"
require "./src/app_config/validator"
require "./src/app_config/provider"
require "./src/app_config/merge_files"
require "./src/common/io/yaml_file_loader"
require './src/common/logger/logger_factory'

module AppConfig
  class Orchestrator

    APP_CONFIG_FILEPATH = "src/config/app_config.yml"

    def initialize(context,
                   validator = nil,
                   merge_files = nil,
                   is_validation_enabled = true
                   )
      @context = context
      @validator = validator || AppConfig::Validator.new()
      @merge_files = merge_files || AppConfig::MergeFiles.new()
      @is_validation_enabled = is_validation_enabled
    end

    def execute(override = nil)
      default = get_default()
      if override.nil?
        override = get_override()
      end
      merged = @merge_files.execute(default, override)
      if @is_validation_enabled
        validate(merged)
      end
      provider = AppConfig::Provider.new(merged)
      @context.set_app_config_provider(provider)
      return provider
    end

    private 

    def get_override()
      filepath = APP_CONFIG_FILEPATH+".local"
      if File.exist?(filepath)
        yaml_file_loader = Common::Io::YamlFileLoader.new(filepath, "App config override file #{filepath} exists, but failed validation.  Please address the failure or delete the file (if you do not wish to override any default application config values): ")          
        return yaml_file_loader.execute      
      else
        return nil
      end
    end

    def get_default()
      yaml_file_loader = Common::Io::YamlFileLoader.new(APP_CONFIG_FILEPATH, "The default app config file #{APP_CONFIG_FILEPATH} failed YAML validation.  This is a required file - please fix the error or get a clean copy before retrying: ")        
      return yaml_file_loader.execute()    
    end

    def validate(config)
      validation_errors = @validator.execute(config)
      unless validation_errors.empty?
        raise Common::ValidationError.new("App Configuration failed validation: ", validation_errors)
      end
    end

  end
end