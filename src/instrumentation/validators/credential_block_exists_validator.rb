module Instrumentation
  module Validators
    class CredentialBlockExistsValidator

      def initialize(user_config_provider, error_message = nil)
        @user_config_provider = user_config_provider
        @error_message = error_message || "Credentials missing in user_config for instrumentation provider "
      end

      def execute(parsed_instrumentors)
        missing = []
        (parsed_instrumentors || []).each do |parsed_instrumentor|
          provider = parsed_instrumentor["provider"]
          unless provider.nil?()
            credential = get_user_config_provider().get_credential(provider)
            if credential.nil?()
              missing.push("'#{provider}'")
            end
          end
        end

        if missing.length>0
          message = missing.join(", ")
          return "#{@error_message}#{message}"
        end

        return nil
      end

      private

      def get_user_config_provider()
        return @user_config_provider
      end

    end
  end
end
