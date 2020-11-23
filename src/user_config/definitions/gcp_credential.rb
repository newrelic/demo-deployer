require "fileutils"
require_relative 'credential'

module UserConfig
  module Definitions
    class GcpCredential < Credential

      def initialize (provider, user_config_query_lambda)
        @provider = provider
        @user_config_query_lambda = user_config_query_lambda
      end

      def get_auth_kind()
        return query("auth_kind")
      end

      def get_service_account_email()
        return query("service_account_email")
      end

      def get_service_account_file()
        return query("service_account_file")
      end

      def get_project()
        return query("project")
      end

      def get_scopes()
        return query("scopes")
      end

      def get_region()
        return query("region")
      end

      def get_secret_key_path()
        return query("secretKeyPath")
      end
      
      def to_h(key_prefix = @provider)
        items = {}
        add_if_exist(items, "auth_kind", get_auth_kind(), key_prefix)
        add_if_exist(items, "service_account_email", get_service_account_email(), key_prefix)
        add_if_exist(items, "service_account_file", get_service_account_file(), key_prefix)
        add_if_exist(items, "project", get_project(), key_prefix)
        add_if_exist(items, "scopes", get_scopes(), key_prefix)
        add_if_exist(items, "secret_key_path", get_secret_key_path(), key_prefix)
        add_if_exist(items, "region", get_region(), key_prefix)
        return items
      end

    end
  end
end
