require "./src/common/validators/not_null_or_empty_validator"

require "./src/user_config/validators/provider_validator_factory"

module UserConfig
  class Validator

    def initialize(
      provider_validator_factory = nil,
      credentials_validator = Common::Validators::NotNullOrEmptyValidator.new("Configuration file is missing credentials section")
      )
      @provider_validator_factory = provider_validator_factory
      @credentials_validator = credentials_validator
    end

    def execute(config)
      credentials = config['credentials']
      validators = [
        lambda { return @credentials_validator.execute(credentials) }
      ]

      lambdas = get_provider_validators(credentials)
      validators.concat(lambdas)

      validator = Common::Validators::Validator.new(validators)
      return validator.execute()
    end

    private
    def get_provider_validator_factory()
      return @provider_validator_factory ||= Validators::ProviderValidatorFactory.new()
    end

    def get_provider_validators(credentials)
      provider_credentials_configs = get_provider_credential_config(credentials)
      return get_provider_validator_factory().create_validators(provider_credentials_configs)
    end

    def get_provider_credential_config(credentials)
      provider_credentials_configs = []
      (credentials || {}).each do |provider, credential|
        credential["provider"] = provider
        provider_credentials_configs.push(credential)
      end
      return provider_credentials_configs
    end

  end
end
