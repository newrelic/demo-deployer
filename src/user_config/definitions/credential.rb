module UserConfig
  module Definitions
      class Credential

        def initialize (provider, user_config_query_lambda)
            @provider = provider
            @user_config_query_lambda = user_config_query_lambda
        end

        def add_if_exist(items, name, value, no_prefix = false)
          unless value.nil?
            if no_prefix
              key = name
            else
              key = "#{@provider}_#{name}"
            end

            items[key] = value
          end
        end

        def query(path)
            return @user_config_query_lambda.call(path)
        end

    end
  end
end
