require 'aws-sdk-core'
require 'aws-sdk-ssm'

module UserConfig
  module Definitions
      class Credential

        def initialize (provider, user_config_query_lambda, env_lambda = nil, ssm_param_lambda = nil)
            @provider = provider
            @user_config_query_lambda = user_config_query_lambda
            @env_lambda = env_lambda || lambda { |name| return env_value_lookup(name) }
            @ssm_param_lambda = ssm_param_lambda || lambda { |name| return aws_ssm_param_lookup(name) }
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
            env_var_name = get_matching_or_nil(/\[(?i)env\:(\w+)\]/, value)
            unless env_var_name.nil?
              return @env_lambda.call(env_var_name)
            end
            aws_ssm_param_name = get_matching_or_nil(/\[(?i)aws_ssm_param\:([a-zA-Z0-9_\-\/]+)\]/, value)
            unless aws_ssm_param_name.nil?
              return @ssm_param_lambda.call(aws_ssm_param_name)
            end
            return value
        end

        def get_matching_or_nil(regex, value)
          matches = regex.match(value)
          unless matches.nil?
            captures = matches.captures
            if captures.length > 0
              unless captures[0].nil?
                unless captures[0].empty?
                  return captures[0]
                end
              end
            end
          end
          return nil
        end

        def env_value_lookup(name)
          return ENV[name]
        end

        def aws_ssm_param_lookup(name)
          # rely on default from aws configuration methods
          instance_credentials = Aws::InstanceProfileCredentials.new()
          options = {
            credentials: instance_credentials
          }
          client = Aws::SSM::Client.new(options)
          resp = client.get_parameter({
            name: name,
            with_decryption: true,
          })
          return resp
        end

        def ensure_created(deployment_path)
        end
  
    end
  end
end
