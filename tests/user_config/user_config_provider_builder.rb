require "json"
require "./src/user_config/orchestrator"

module Tests
  module UserConfig
    class UserConfigProviderBuilder

      def initialize(parent_builder)
        @parent_builder = parent_builder
        @content = {}
        @user_config = nil
      end

      def with_aws(api_key ="API_KEY", secret_key = "SECRET_KEY", secret_key_path = "/path/pem", region = "a_region")
        with_credentials("aws", {"apiKey" => "#{api_key}"})
        with_credentials("aws", {"secretKey" => "#{secret_key}"})
        with_credentials("aws", {"secretKeyPath" => "#{secret_key_path}"})
        with_credentials("aws", {"region" => "#{region}"})
        return @parent_builder
      end

      def with_azure(client_id ="CLIENT_ID", tenant = "TENANT", subscription_id = "SUBSCRIPTION_ID", secret = "SECRET", region = "a_region", ssh_public_key_path = nil, secret_key_path = nil)
        with_credentials("azure", {"client_id" => "#{client_id}"})
        with_credentials("azure", {"tenant" => "#{tenant}"})
        with_credentials("azure", {"subscription_id" => "#{subscription_id}"})
        with_credentials("azure", {"secret" => "#{secret}"})
        with_credentials("azure", {"region" => "#{region}"})
        ssh_public_key_path ||= __FILE__
        with_credentials("azure", {"sshPublicKeyPath" => "#{ssh_public_key_path}"})
        secret_key_path ||= __FILE__
        with_credentials("azure", {"sshPublicKeyPath" => "#{secret_key_path}"})        
        return @parent_builder
      end

      def with_new_relic(license_key ="LICENSE_KEY", collector_url = "COLLECTOR_URL")
        with_credentials("newrelic", {"licenseKey" => "#{license_key}"})
        with_credentials("newrelic", {"collector" => "#{collector_url}"})
        return @parent_builder
      end
      
      def with_git_credential(username, token)
        with_credentials("git", {"#{username}" => "#{token}"})
        return @parent_builder
      end

      def with_secrets(key, value)
        with_credentials("secrets", { "#{key}" => "#{value}" })
        return @parent_builder
      end

      def with_credentials(provider, config)
        credentials = get_or_create(@content, "credentials", {})
        provider_content = get_or_create(credentials, provider, {})
        merged = provider_content.merge(config)
        credentials[provider] = merged
        return @parent_builder
      end

      def build(context)
        return @user_config ||= createInstance(context)
      end

      private
      def get_or_create(instance, key, default)
        found = instance[key]
        if found.nil?
          instance[key] = default
        end
        return instance[key]
      end

      def createInstance(context)
        get_or_create(@content, "credentials", {})
        orchestrator = ::UserConfig::Orchestrator.new(context, nil, nil, false)
        return orchestrator.execute(@content.to_json())
      end

    end
  end
end
