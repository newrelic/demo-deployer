module UserConfig
  module Definitions
      class Credential

        def initialize (provider, user_config_query_lambda, env_lambda = nil)
            @provider = provider
            @user_config_query_lambda = user_config_query_lambda
            @env_lambda = env_lambda || lambda { |name| return ENV[name] }
        end

        def add_if_exist(items, name, value, key_prefix = nil)
          unless value.nil?
              key = name
              unless key_prefix.nil?
                key = "#{key_prefix}_#{key}"
              end

            items[key] = value
          end
        end

        def query(path)
            value = @user_config_query_lambda.call(path)
            if value == "" || value.kind_of?(Array) || value.kind_of?(Hash)
              return value
            end
            env_var_name = get_matching_env_or_nil(value)
            if env_var_name.nil?
              return value
            end
            return @env_lambda.call(env_var_name)
        end

        def get_matching_env_or_nil(value)
          env_regex = /\[(?i)env\:(\w+)\]/
          matches = env_regex.match(value)
          unless matches.nil?
            captures = matches.captures
            if captures.length > 0
              return captures[0]
            end
          end
          return nil
        end

    end
  end
end
