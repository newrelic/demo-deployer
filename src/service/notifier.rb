require './src/command_line/orchestrator'
require "./src/common/definitions/deployment"

require 'aws-sdk-dynamodb'

module Service
  class Notifier

    def initialize(
        context,
        dynamodb_client_lambda = nil
        )
      @context = context
      @dynamodb_client_lambda ||= lambda {return Aws::DynamoDB::Client.new()}
      @dynamodb_client = nil
    end

    def execute(deployment, code)
        table_name = get_command_line_provider().get_notification_table_name()
        if table_name.empty?
            return
        end
        client = get_dynamodb_client()
        message_id = deployment.get_deploy_config_filename()
        expirationTime = Time.now()+(60*60)
        item = {
            "MessageId": message_id,
            "Code": code,
            "ExpirationTime": expirationTime.to_i,
        }
        Common::Logger::LoggerFactory.get_logger().info("notifying item:#{item}")
        client.put_item({
            table_name: table_name,
            item: item,
        })
    end

    private
    def get_command_line_provider()
      return @context.get_command_line_provider()
    end

    def get_dynamodb_client()
        @dynamodb_client ||= @dynamodb_client_lambda.call()
        return @dynamodb_client
    end

  end
end