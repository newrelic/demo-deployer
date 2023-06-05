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
      @dynamodb_client_lambda ||= lambda {return create_dynamodb_client()}
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

    def create_dynamodb_client()
      aws_credential = @context.get_user_config_provider().get_aws_credential()
      credential = Aws::Credentials.new(aws_credential.get_access_key(), aws_credential.get_secret_key(), aws_credential.get_session_token())
      client = Aws::DynamoDB::Client.new({region: aws_credential.get_region(), credentials: credential})
      return client
    end

  end
end