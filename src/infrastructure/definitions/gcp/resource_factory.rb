require  "./src/infrastructure/definitions/gcp/compute_resource"

module Infrastructure
  module Definitions
    module Gcp
      class ResourceFactory

        def initialize(user_config_provider, tag_provider, default_user_name = "compute-user")
          @user_config_provider = user_config_provider
          @default_user_name = default_user_name
          @tag_provider = tag_provider
        end

        def create(config_resource)
          resource_id = config_resource["id"]
          tags = @tag_provider.get_resource_tags(resource_id)
          user_name = (config_resource["user_name"] || @default_user_name)
          credential = get_credential()

          case config_resource["type"]
            when "compute"
              source_image = config_resource["source_image"]
              resource = ComputeResource.new(resource_id, credential, config_resource["size"], user_name, tags, source_image)
              return resource
          end

          return nil
        end

        private
        def get_credential()
          return @user_config_provider.get_credential("gcp")
        end

      end
    end
  end
end