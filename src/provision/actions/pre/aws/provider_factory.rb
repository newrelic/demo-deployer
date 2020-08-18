require "./src/common/type_repository"

require "./src/provision/actions/pre/aws/fetch_lambda_api_id"

module Provision
  module Actions
    module Pre
      module Aws
        class ProviderFactory

          def initialize(context)
            @context = context
          end

          def create(resource)
            repository = get_repository()
            type = repository.get(resource)
            if type.nil? == false
              return type.new(@context)
            end
            return nil
          end

          private
          def get_supported_types()
            @supported_types ||= {
              "lambda" => Provision::Actions::Pre::Aws::FetchLambdaApiId
            }
          end

          def get_key_lookup_lambda()
            return lambda {|resource| return resource.get_type()}
          end

          def get_repository()
            return @type_repository ||= Common::TypeRepository.new(get_supported_types(), get_key_lookup_lambda(), lambda { return nil })
          end

        end

      end
    end
  end
end