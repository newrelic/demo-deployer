module Deployment
  class CredentialExistValidator

    def initialize(user_config_provider, error_message = nil)
      @user_config_provider = user_config_provider
      @error_message = error_message || "The provider credential is not defined for:"
    end

    def execute(provider)
      credential = @user_config_provider.get_credential(provider)
      if credential.nil?()
        return "#{@error_message} #{provider}"
      end

      return nil
    end

  end
end