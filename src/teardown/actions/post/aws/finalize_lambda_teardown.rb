require "./src/common/type_repository"
require "./src/common/logger/logger_factory"
require "./src/common/aws/utilities/api_gateway"

require "./src/teardown/actions/post/aws/finalize_lambda_teardown"

module Teardown
  module Actions
    module Post
      module Aws
        class FinalizeLambdaTeardown

          def initialize(context, api_gateway_client = nil, sleep_lambda = nil)
            @context = context
            @api_gateway_client = api_gateway_client
            @sleep_lambda = sleep_lambda || lambda { sleep get_aws_api_gateway_sleep_time_seconds() }
          end
  
          def execute(resource)
            Common::Logger::LoggerFactory.get_logger().debug("Teardown/Actions/Post/Aws/FinalizeLambdaTeardown execute(#{resource.get_id()})")
            credential = resource.get_credential()
            gateway_name = get_lambda_function_name(resource)
            api_gateway = get_api_gateway_client(credential)
            api_gateway.delete_api_gateway_by_name(gateway_name)
            # Need to slow-down as aws/api gateway does NOT allow deleting at a faster rate
            @sleep_lambda.call()
            return true
          end

          private
          def get_lambda_function_name(resource)
            return "#{get_deployment_name()}-#{resource.get_id()}-api"
          end

          def get_deployment_name()
            deployment_name = @context.get_command_line_provider().get_deployment_name()
          end

          def get_aws_api_gateway_sleep_time_seconds()
            @context.get_app_config_provider().get_aws_api_gateway_sleep_time_seconds()
          end

          def get_api_gateway_client(credential)
            return (@api_gateway_client ||= Common::Aws::Utilities::ApiGateway.new(credential))
          end

        end

      end
    end
  end
end