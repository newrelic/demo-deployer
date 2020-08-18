require './src/infrastructure/definitions/aws/aws_resource'

module Infrastructure
  module Definitions
    module Aws
      class R53IpResource < AwsResource

        def initialize (id, credential, domain, listeners, reference_id)
          super(id, "r53ip", credential, AwsResource::R53_GROUP_ID)
          @domain = domain
          @listeners = listeners
          @reference_id = reference_id
        end
        
        def get_domain()
          return @domain
        end
        
        def get_listeners()
          return @listeners || []
        end

        def get_reference_id()
          return @reference_id
        end

        def get_dns()
          return "#{get_id()}.#{get_domain()}"
        end

      end
    end
  end
end
