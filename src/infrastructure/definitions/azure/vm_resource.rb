require './src/infrastructure/definitions/azure/azure_resource'

module Infrastructure
  module Definitions
    module Azure
      class VmResource < AzureResource

        def initialize (id, credential, size, user_name, tags)
          super(id, "vm", credential, AzureResource::VM_GROUP_ID)
          @size = size
          @user_name = user_name
          @tags = tags
        end

        def get_size()
          return @size
        end

        def get_user_name()
          return @user_name
        end

        def get_tags()
          return @tags.merge({})
        end

        def is_windows?()
          return false
        end

      end
    end
  end
end