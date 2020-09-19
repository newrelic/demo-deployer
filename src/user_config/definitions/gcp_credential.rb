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
        return nil
      end
      
      def to_h()
        items = {}
        add_if_exist(items, "auth_kind", get_auth_kind())
        add_if_exist(items, "service_account_email", get_service_account_email())
        add_if_exist(items, "service_account_file", get_service_account_file())
        add_if_exist(items, "project", get_project())
        add_if_exist(items, "scopes", get_scopes())
        add_if_exist(items, "region", get_region())
        return items
      end

    end
  end
end