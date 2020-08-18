require 'json'

module Common
  class JsonParser

    def get_children(config, key)
      content = []
      unless config.nil?
        config_json = JSON.parse(config)
        if (config_json.key?(key))
          content = config_json[key]
        end
      end
      return content
    end
    
    def get(config, key)
      unless config.nil?
        config_json = JSON.parse(config)
        if (config_json.key?(key))
          return config_json[key]
        end
      end
      return nil
    end

  end
end