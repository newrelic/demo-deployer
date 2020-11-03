require './src/user_config/credential_factory'

module UserConfig
  class Provider

    def initialize(context, user_config_file, credential_factory = nil)
      @context = context
      @config_file = user_config_file
      @credential_factory = credential_factory || UserConfig::CredentialFactory.new()
    end

    def get_credential(provider)
      config_credential = @config_file['credentials'][provider]
      unless config_credential.nil?()
        return @credential_factory.create(@context, config_credential, provider)
      end
      return nil
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

  end
end

