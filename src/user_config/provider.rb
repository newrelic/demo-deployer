require './src/user_config/credential_factory'

module UserConfig
  class Provider

    def initialize(user_config_file, credential_factory = nil)
      @config_file = user_config_file
      @credential_factory = credential_factory || UserConfig::CredentialFactory.new()
    end

    def get_credential(provider)
      config_credential = @config_file['credentials'][provider]
      unless config_credential.nil?()
        return @credential_factory.create(config_credential, provider)
      end
      return nil
    end

    def ensure_all_created(deployment_path)
      unless @config_file.nil?
        unless @config_file['credentials'].nil?
          @config_file['credentials'].each do |item|
            credential = get_credential(item[0])
            unless credential.nil?
              credential.ensure_created(deployment_path)
            end
          end
        end
      end
    end

    def get_new_relic_credential()
      return get_credential('newrelic')
    end

    def get_aws_credential()
      return get_credential('aws')
    end

    def get_git_credentials()
      return get_credential('git')
    end

    def get_secrets_credential()
      return get_credential('secrets')
    end
  end
end

