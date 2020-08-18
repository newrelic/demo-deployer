require "./src/common/type_repository"
require "./src/provision/actions/pre/aws/provider_factory"

module Provision
  module Actions
    module Pre
      class PreActionsFactory

        def initialize(context, supported_types = nil, type_repository = nil)
          @context = context
          @supported_types = supported_types
          @type_repository = type_repository
        end

        def create(resource)
          repository = get_repository()
          type = repository.get(resource)
          if type.nil? == false
            instance = type.new(@context)
            return instance.create(resource)
          end
          return nil
        end

        private
        def get_supported_types()
          @supported_types ||= {
            "aws" => Provision::Actions::Pre::Aws::ProviderFactory
          }
        end

        def get_key_lookup_lambda()
          return lambda {|resource| return resource.get_provider()}
        end
        
        def get_repository()
          return @type_repository ||= Common::TypeRepository.new(get_supported_types(), get_key_lookup_lambda(), lambda { return nil })
        end

      end
    end
  end
end