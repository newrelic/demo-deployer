require 'json'

module Services
  class ProviderCredentialValidator

    def initialize(user_config_provider, error_message = nil)
      @user_config_provider = user_config_provider
      @error_message = error_message || "Error"
    end

    def execute(services)
      invalid = []
      (services || []).each do |service|
        provider_credential = service['provider_credential']
        unless provider_credential.nil?
          credential = @user_config_provider.get_credential(provider_credential)
          if credential.nil?
            invalid.push("#{JSON.generate(service)}")
          end
        end
      end
      if invalid.length>0
        return "#{@error_message} #{invalid.join(", ")}"
      end
      return nil
    end

  end
end