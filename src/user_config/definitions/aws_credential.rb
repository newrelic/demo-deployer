require "fileutils"
require_relative 'credential'

module UserConfig
  module Definitions
    class AwsCredential < Credential

      def initialize (provider, user_config_query_lambda)
        @secret_key_path = nil
        super(provider, user_config_query_lambda)
      end

      def get_access_key()
        return query("apiKey")
      end

      def get_secret_key()
        return query("secretKey")
      end

      def get_session_token()
        return query ("sessionToken")
      end

      def get_secret_key_name()
        value = query("secretKeyName")
        unless value.nil?
          return value
        end
        secrect_key_path = get_secret_key_path()
        unless secrect_key_path.nil?
          return File.basename(secrect_key_path, ".*")
        end
        return nil
      end

      def get_secret_key_path()
        if @secret_key_path.nil?
          return query("secretKeyPath")
        end
        return @secret_key_path
      end
      
      def get_secret_key_data()
        return query("secretKeyData")
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
      
      def ensure_created(deployment_path)
        default_key_path = get_secret_key_path()
        name = get_secret_key_name()
        data = get_secret_key_data()
        if default_key_path.nil? && !name.empty? && !data.empty?
          # no key path in config, but key name and data specified
          filename = "#{name}.pem"
          file_path = "#{deployment_path}/#{filename}"
          write_config(file_path, data)
          Common::Tasks::ProcessTask.new("sudo chmod 400 #{file_path}", "./").wait_to_completion()
          @secret_key_path = file_path
        end
      end

      def to_h(key_prefix = @provider)
        items = {}
        add_if_exist(items, "access_key", get_access_key(), key_prefix)
        add_if_exist(items, "secret_key", get_secret_key(), key_prefix)
        add_if_exist(items, "session_token", get_session_token(), key_prefix)
        add_if_exist(items, "secret_key_name", get_secret_key_name(), key_prefix)
        add_if_exist(items, "secret_key_path", get_secret_key_path(), key_prefix)
        add_if_exist(items, "region", get_region(), key_prefix)
        return items
      end

      private
      def write_config(filepath, content)
        file_writer = Common::Io::FileWriter.new(filepath, content)
        file_writer.execute()
      end

    end
  end
end
