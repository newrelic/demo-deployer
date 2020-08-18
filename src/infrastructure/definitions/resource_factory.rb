require  "./src/infrastructure/definitions/resource_data"
require  "./src/infrastructure/definitions/aws/resource_factory"
require  "./src/infrastructure/definitions/azure/resource_factory"
require  "./src/common/type_repository"


module Infrastructure
  module Definitions
    class ResourceFactory

      def initialize(
          user_config_provider,
          tag_provider,
          type_repository = nil,
          supported_types = nil
        )
        @user_config_provider = user_config_provider
        @tag_provider = tag_provider
        @type_repository = type_repository
        @supported_types = supported_types
      end

      def create(config_resource)
        repository = get_repository()
        type = repository.get(config_resource)
        resource = type.new(@user_config_provider, @tag_provider).create(config_resource)
        display_name = config_resource["display_name"]
        unless display_name.nil?
          resource.set_display_name(display_name)
        end
        return resource
      end

      private
      def get_key_resolver_lambda()
        return lambda {|config_resource| return config_resource["provider"]}
      end

      def get_repository()
        return @type_repository ||= Common::TypeRepository.new(get_supported_types(), get_key_resolver_lambda())
      end

      def get_supported_types()
        return @supported_types ||= {
          "aws" => Infrastructure::Definitions::Aws::ResourceFactory,
          "azure" => Infrastructure::Definitions::Azure::ResourceFactory
        }
      end

    end
  end
end
