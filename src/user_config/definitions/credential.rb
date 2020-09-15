module UserConfig
  module Definitions
      class Credential

        def initialize (provider, user_config_query_lambda)
            @provider = provider
            @user_config_query_lambda = user_config_query_lambda
        end

        def add_if_exist(items, name, value)
          unless value.nil?
            key = "#{@provider}_#{name}"
            items[key] = value
          end
        end

        def query(path)
            return @user_config_query_lambda.call(path)
        end

    end
  end
end
