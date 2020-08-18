require "./src/common/type_repository"
require "./src/common/logger/logger_factory"
require "./src/common/aws/utilities/api_gateway"

module Provision
  module Actions
    module Pre
      module Aws
        class FetchLambdaApiId

          def initialize(context, api_gateway_client = nil)
            @context = context
            @api_gateway_client = api_gateway_client
          end
  
          def execute(resource)
            Common::Logger::LoggerFactory.get_logger().debug("Provision/Actions/Pre/Aws/FetchLambdaApiId execute(#{resource.get_id()})")
            credential = resource.get_credential()
            gateway_name = get_lambda_function_name(resource)
            api_gateway = get_api_gateway_client(credential)
            api_id = api_gateway.get_api_gateway_id_by_name(gateway_name)
            resource.set_api_id(api_id)
            return true
          end

          private
          def get_lambda_function_name(resource)
            return "#{get_deployment_name()}-#{resource.get_id()}_api"
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