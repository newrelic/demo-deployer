require "fileutils"
require_relative 'credential'

module UserConfig
  module Definitions
    class AzureCredential < Credential

      def initialize (provider, user_config_query_lambda)
        super(provider, user_config_query_lambda)
      end

      def get_client_id()
        return query("client_id")
      end

      def get_tenant()
        return query("tenant")
      end

      def get_subscription_id()
        return query("subscription_id")
      end

      def get_secret()
        return query("secret")
      end
      
      def get_ssh_public_key()
        filepath = get_ssh_public_key_path()
        return (@ssh_public_key_path ||= File.read(filepath))
      end

      def get_ssh_public_key_path()
        return query("sshPublicKeyPath")
      end

      def get_secret_key_name()
        return File.basename(get_secret_key_path())
      end

      def get_secret_key_path()
        return get_ssh_public_key_path().gsub(/\.pub/i, '')
      end

      def get_region()
        return query("region")
      end

      def to_h(key_prefix = @provider)
        items = {}
        add_if_exist(items, "client_id", get_client_id(), key_prefix)
        add_if_exist(items, "tenant", get_tenant(), key_prefix)
        add_if_exist(items, "subscription_id", get_subscription_id(), key_prefix)
        add_if_exist(items, "secret", get_secret(), key_prefix)
        add_if_exist(items, "secretKeyPath", get_secret_key_path(), key_prefix)
        add_if_exist(items, "region", get_region(), key_prefix)
        add_if_exist(items, "ssh_public_key", get_ssh_public_key(), key_prefix)
        return items
      end

    end
  end
end
