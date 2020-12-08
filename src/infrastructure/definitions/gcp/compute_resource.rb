require './src/infrastructure/definitions/gcp/gcp_resource'

module Infrastructure
  module Definitions
    module Gcp
      class ComputeResource < GcpResource

        def initialize (id, credential, size, user_name, tags, source_image = nil)
          super(id, "compute", credential, GcpResource::COMPUTE_GROUP_ID)
          @size = size
          @user_name = user_name
          @tags = tags
          @source_image = source_image || "projects/centos-cloud/global/images/centos-7-v20191210"
        end

        def get_size()
          return @size
        end

        def get_user_name()
          return @user_name
        end
        
        def get_tags()
          return @tags
        end

        def get_source_image()
          return @source_image
        end

        def is_windows?()
          return false
        end

      end
    end
  end
end