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
      options = get_aws_options(aws_credential)
      client = Aws::DynamoDB::Client.new(options)
      return client
    end

    def get_aws_options(aws_credential)
      options = {}
      region = aws_credential.get_region()
      if is_not_empty?(region)
        options = options.merge({region: region})
      end
      access_key = aws_credential.get_access_key()
      secret_key = aws_credential.get_secret_key()
      if is_not_empty?(access_key) && is_not_empty?(secret_key)
        credential = Aws::Credentials.new(access_key, secret_key, aws_credential.get_session_token())
        options = options.merge({credentials: credential})
      end
      return options
    end

    def is_not_empty?(value)
      unless value.nil?
        unless value.empty?
          return true
        end
      end
      return false
    end

  end
end