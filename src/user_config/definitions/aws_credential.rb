require "fileutils"
require_relative 'credential'

module UserConfig
  module Definitions
    class AwsCredential < Credential

      def initialize (provider, user_config_query_lambda)
        super(provider, user_config_query_lambda)
      end

      def get_access_key()
        return query("apiKey")
      end

      def get_secret_key()
        return query("secretKey")
      end

      def get_secret_key_name()
        secrect_key_path = get_secret_key_path()
        unless secrect_key_path.nil?
          return File.basename(secrect_key_path, ".*")
        end
        return nil
      end

      def get_secret_key_path()
        return query("secretKeyPath")
      end

      def get_region()
        return query("region")
      end

      def get_availability_zone()
        region = get_region()
        availability_zone = query("availability_zone")
        unless availability_zone.nil?
          return "#{region}#{availability_zone}"
        end
        return nil
      end

      def to_h(key_prefix = @provider)
        items = {}
        add_if_exist(items, "access_key", get_access_key(), key_prefix)
        add_if_exist(items, "secret_key", get_secret_key(), key_prefix)
        add_if_exist(items, "secret_key_name", get_secret_key_name(), key_prefix)
        add_if_exist(items, "secret_key_path", get_secret_key_path(), key_prefix)
        add_if_exist(items, "region", get_region(), key_prefix)
        return items
      end

    end
  end
end
