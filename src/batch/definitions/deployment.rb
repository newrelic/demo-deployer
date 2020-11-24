require "json"
require "./src/common/io/directory_service"
require "./src/common/install/params"

module Batch
  module Definitions
    class Deployment

      def initialize(user_config_filepath, deploy_config_filepath)
        @user_config_filepath = user_config_filepath
        @deploy_config_filepath = deploy_config_filepath
      end


      def get_user_config_filepath()
        return @user_config_filepath
      end

      def get_user_config_filename()
        return strip_to_name(@user_config_filepath)
      end


      def get_deploy_config_filepath()
        return @deploy_config_filepath
      end

      def get_deploy_config_filename()
        return strip_to_name(@deploy_config_filepath)
      end


      def get_deployment_name()
        username = get_user_config_filename()
        deployname = get_deploy_config_filename()
        return "#{username}-#{deployname}"
      end


      def to_s()
        return "Deployment deployment_name:#{get_deployment_name()} user_config_filepath:#{@user_config_filepath} deploy_config_filepath:#{@deploy_config_filepath}"
      end

      def to_h()
        items = {
          "get_deployment_name": get_deployment_name(),
          "user_config_filepath": @user_config_filepath,
          "deploy_config_filepath": @deploy_config_filepath
        }
        return items
      end

      private
      def strip_to_name(filepath)
        unless filepath.nil?
          filename = File.basename(filepath)
          split = filename.split('.').first
          return split
        end
        return nil
      end

    end
  end
end