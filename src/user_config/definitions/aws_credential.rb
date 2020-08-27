require "fileutils"

module UserConfig
  module Definitions
    class AwsCredential

      def initialize (user_config_query_lambda)
        @user_config_query_lambda = user_config_query_lambda
      end

      def get_api_key()
        return @user_config_query_lambda.call("apiKey")
      end

      def get_secret_key()
        return @user_config_query_lambda.call("secretKey")
      end

      def get_secret_key_name()
        secrect_key_path = get_secret_key_path()
        unless secrect_key_path.nil?
          return File.basename(secrect_key_path, ".*")
        end
        return nil
      end

      def get_secret_key_path()
        return @user_config_query_lambda.call("secretKeyPath")
      end

      def get_region()
        return @user_config_query_lambda.call("region")
      end

      def to_h()
        return {
          "api_key": get_api_key(),
          "secret_key": get_secret_key(),
          "secret_key_name": get_secret_key_name(),
          "secret_key_path": get_secret_key_path(),
          "region": get_region()
        }
      end

    end
  end
end