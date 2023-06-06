require './src/common/io/file_writer'
require './src/command_line/orchestrator'
require "./src/common/definitions/deployment"

require 'aws-sdk-sqs'

module Service
  class DeploymentRepository

    def initialize(
        context,
        sqs_client_lambda = nil
        )
      @context = context
      @sqs_client_lambda ||= lambda {return create_sqs_client()}
      @sql_client = nil
    end

    def wait_next()
        while true
            wait_time_seconds = get_command_line_provider().get_wait_time_seconds()
            queue_url = get_command_line_provider().get_queue_url()
            resp = get_sqs_client().receive_message({
                queue_url: queue_url,
                wait_time_seconds: wait_time_seconds,
                max_number_of_messages: 1,
            })
            if resp.messages.length() > 0
                message_id = resp.messages[0].message_id
                receipt_handle = resp.messages[0].receipt_handle
                body = resp.messages[0].body
                attributes = resp.messages[0].attributes
                Common::Logger::LoggerFactory.get_logger().info("Got new message with message_id:#{message_id}")
                get_sqs_client().delete_message({
                    queue_url: queue_url,
                    receipt_handle: receipt_handle,
                })
                user_config_filename = @context.get_command_line_provider().get_user_config_filepath()
                deploy_config_filename = write_deploy_config(message_id, body)
                deployment = Common::Definitions::Deployment.new(user_config_filename, deploy_config_filename)
                return deployment
            end
            sleep 1
        end
    end

    private
    def get_user_config_provider()
      return @context.get_user_config_provider()
    end

    def get_command_line_provider()
      return @context.get_command_line_provider()
    end

    def get_sqs_client()
        @sqs_client ||= @sqs_client_lambda.call()
        return @sqs_client
    end

    def create_sqs_client()
      aws_credential = @context.get_user_config_provider().get_aws_credential()
      options = get_aws_options(aws_credential)
      client = Aws::SQS::Client.new(options)
      return client
    end

    def get_aws_options(aws_credential)
      options = {}
      region = aws_credential.get_region()
      if is_not_empty?(region)
        options.merge({region: region})
      end
      access_key = aws_credential.get_access_key()
      secret_key = aws_credential.get_secret_key()
      if is_not_empty?(access_key) && is_not_empty?(secret_key)
        credential = Aws::Credentials.new(access_key, secret_key, aws_credential.get_session_token())
        options.merge({credentials: credential})
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

    def write_deploy_config(message_id, content)
        app_config_provider = @context.get_app_config_provider()
        execution_path = app_config_provider.get_execution_path()
        filename = "#{message_id}.local.json"
        file_path = "#{execution_path}/#{filename}"
        file_writer = Common::Io::FileWriter.new(file_path, content)
        file_writer.execute()
        return file_path
    end

  end
end