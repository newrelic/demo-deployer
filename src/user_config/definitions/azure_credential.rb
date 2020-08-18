require "fileutils"

module UserConfig
  module Definitions
    class AzureCredential

      def initialize (user_config_query_lambda)
        @user_config_query_lambda = user_config_query_lambda
      end

      def get_client_id()
        return @user_config_query_lambda.call("client_id")
      end

      def get_tenant()
        return @user_config_query_lambda.call("tenant")
      end

      def get_subscription_id()
        return @user_config_query_lambda.call("subscription_id")
      end

      def get_secret()
        return @user_config_query_lambda.call("secret")
      end
      
      def get_ssh_public_key()
        filepath = get_ssh_public_key_path()
        return (@ssh_public_key_path ||= File.read(filepath))
      end

      def get_ssh_public_key_path()
        return @user_config_query_lambda.call("sshPublicKeyPath")
      end

      def get_secret_key_name()
        return File.basename(get_secret_key_path(), ".*")
      end

      def get_secret_key_path()
        return @user_config_query_lambda.call("secretKeyPath")
      end        

      def get_region()
        return @user_config_query_lambda.call("region")
      end
      
      def to_h()
        return {
          "client_id": get_client_id(),
          "tenant": get_tenant(),
          "subscription_id": get_subscription_id(),
          "secret": get_secret(),
          "secretKeyPath": get_secret_key_path(),
          "region": get_region(),
          "ssh_public_key": get_ssh_public_key()
        }
      end

    end
  end
end