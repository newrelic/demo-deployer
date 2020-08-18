require './src/infrastructure/definitions/resource_data'

module Infrastructure
  module Definitions
    module Azure
      class AzureResource < ResourceData

        VM_GROUP_ID = 1

        def initialize (id, type, credential, provision_group)
          super(id, "azure", provision_group)
          @type = type
          @credential = credential
          @provision_group = provision_group
        end

        def get_type()
          return @type
        end

        def get_credential()
          return @credential
        end

        def get_group()
          return @provision_group
        end

      end
    end
  end
end