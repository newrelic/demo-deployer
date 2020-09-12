require "fileutils"

module UserConfig
  module Definitions
    class GcpCredential

      def initialize (user_config_query_lambda)
        @user_config_query_lambda = user_config_query_lambda
      end

      def get_auth_kind()
        return @user_config_query_lambda.call("auth_kind")
      end

      def get_service_account_email()
        return @user_config_query_lambda.call("service_account_email")
      end

      def get_service_account_file()
        return @user_config_query_lambda.call("service_account_file")
      end

      def get_project()
        return @user_config_query_lambda.call("project")
      end

      def get_scopes()
        return @user_config_query_lambda.call("scopes")
      end

      def get_region()
        return @user_config_query_lambda.call("region")
      end
      
      def to_h()
        return {
          "auth_kind": get_auth_kind(),
          "service_account_email": get_service_account_email(),
          "service_account_file": get_service_account_file(),
          "project": get_project(),
          "scopes": get_scopes(),
          "region": get_region()
        }
      end

    end
  end
end