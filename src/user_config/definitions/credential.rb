module UserConfig
  module Definitions
      class Credential

        def initialize (provider, user_config_query_lambda)
            @provider = provider
            @user_config_query_lambda = user_config_query_lambda
        end

        def add_if_exist(items, name, value, key_prefix)
          unless value.nil?
              key = name
              unless key_prefix.nil?
                key = "#{key_prefix}_#{key}"
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
