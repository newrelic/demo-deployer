require "./src/common/validation_error"

module UserConfig
  class Parser

    def execute(user_config)
      begin
        user_config = JSON.parse(user_config)
      rescue Exception => ex
        raise Common::ValidationError.new("User Configuration failed JSON parsing", ex.message)
      end
      return user_config
    end
  end
end

