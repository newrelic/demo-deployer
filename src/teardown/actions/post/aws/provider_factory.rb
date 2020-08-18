require "./src/common/type_repository"

require "./src/teardown/actions/post/aws/finalize_lambda_teardown"

module Teardown
  module Actions
    module Post
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
              "lambda" => Teardown::Actions::Post::Aws::FinalizeLambdaTeardown
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